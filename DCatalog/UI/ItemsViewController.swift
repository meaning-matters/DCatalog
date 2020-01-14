//
//  ItemsViewController.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 11/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import UIKit
import Alamofire

class ItemsViewController : UITableViewController
{
    // MARK: - User Interface
    private var contentHeight: CGFloat = 0

    // MARK: - DI Objects
    private var itemSource: ItemSource
    private var itemRepository: ItemRepository

    // MARK: - View Model Bindings
    private var errorObserver: NSKeyValueObservation?
    private var isLoadingObserver: NSKeyValueObservation?
    private var itemsObserver: NSKeyValueObservation?

    private lazy var viewModel: ItemsViewModel =
    {
        return ItemsViewModel(itemSource: self.itemSource, itemRepository: self.itemRepository)
    }()

    // MARK: - Lifecycle & View Controller

    init(itemSource: ItemSource, itemRepository: ItemRepository)
    {
        self.itemSource = itemSource
        self.itemRepository = itemRepository

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        bindViewModel()

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(ItemsViewController.handleRefresh(_:)),
                                            for: .valueChanged)

        tableView.register(UINib(nibName: ItemCell.nibName, bundle: nil), forCellReuseIdentifier: ItemCell.identifier)

        tableView.tableFooterView = UIView() // Hide bottom separators without cells.
        title = self.viewModel.title
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        viewModel.loadInitialItems()
    }

    // MARK: - Local

    @objc private func handleRefresh(_ refreshControl: UIRefreshControl)
    {
        self.viewModel.loadNewerItem()
    }

    private func bindViewModel()
    {
        errorObserver = viewModel.observe(\.errorString)
        { [weak self] (viewModel, change) in
            self?.showMessage(viewModel.errorString)
        }

        isLoadingObserver = viewModel.observe(\.isLoading)
        { [weak self] (viewModel, change) in
            if !viewModel.isLoading
            {
                if self?.tableView.refreshControl?.isRefreshing ?? false
                {
                    let y = -(self?.tableView.refreshControl?.bounds.size.height ?? 0)
                    self?.tableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
        }

        itemsObserver = viewModel.observe(\.items)
        { [unowned self] (viewModel, change) in
            if self.tableView.numberOfSections == self.numberOfSections(in: self.tableView)
            {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            else
            {
                self.tableView.reloadData()
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let reachedBottom = (scrollView.contentOffset.y >= 0) &&
                            (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) &&
                            (scrollView.contentSize.height > contentHeight)
        if reachedBottom
        {
            contentHeight = scrollView.contentSize.height

            viewModel.fetchLimit += 10
            viewModel.loadOlderItems()
        }
    }
}

extension ItemsViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return (viewModel.items.count > 0) ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier, for: indexPath) as! ItemCell

        cell.item = viewModel.items[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            viewModel.deleteItem(at: indexPath.row)
        }
    }
}

extension UIViewController
{
    func showMessage(_ message: String?, duration: TimeInterval = 2)
    {
        guard let message = message else { return }

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration)
        {
            alertController.dismiss(animated: true)
        }
    }
}
