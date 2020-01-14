//
//  ItemsViewModel.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 13/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation

/// Model class for the list of items.
@objcMembers class ItemsViewModel : NSObject
{
    /// Maximum number of items that are fetched from the database and shown on screen.
    var fetchLimit: Int = 10
    {
        didSet
        {
            saveAndUpdate()
        }
    }

    // MARK: - DI Objects
    private var itemSource: ItemSource
    private var itemRepository: ItemRepository

    // MARK: - Public Property
    var title: String = "Digidentity Catalog"

    // MARK: - Bindable Public Properties
    dynamic var items: [ItemModel] = []
    dynamic var errorString: String? = nil
    dynamic var isLoading: Bool = false

    // MARK: - Lifecycle

    init(itemSource: ItemSource, itemRepository: ItemRepository)
    {
        self.itemSource = itemSource
        self.itemRepository = itemRepository

        super.init()
    }

    // MARK: - Public Functions

    /// Loads the newest items from the server.
    ///
    /// This function must be called first when the app starts.
    func loadInitialItems()
    {
        loadItems(sinceId: nil, maxId: nil)
    }

    /// Loads items newer then the current ones from the server.
    ///
    /// This function should be called after `items` is populated by `loadInitialItems()`. If `items` is still empty,
    /// the newest items will be loaded from the server (just like `loadInitialItems()`).
    func loadNewerItem()
    {
        loadItems(sinceId: items.first?.id, maxId: nil)
    }

    /// Loads items older then the current ones from the server.
    ///
    /// This function should be called after `items` is populated by `loadInitialItems()`. If `items` is still empty,
    /// the newest items will be loaded from the server (just like `loadInitialItems()`).
    func loadOlderItems()
    {
        loadItems(sinceId: nil, maxId: items.last?.id)
    }

    /// Deletes an item on the server and if that succeeds also from the local database.
    ///
    /// - Parameter index: Index of the item to delete.
    func deleteItem(at index: Int)
    {
        itemSource.deleteItem(id: items[index].id)
        { (error) in
            self.errorString = error?.localizedDescription

            if error == nil
            {
                self.itemRepository.deleteItem(with: self.items[index].id)
            }

            self.saveAndUpdate()
        }
    }

    // MARK: - Local

    private func loadItems(sinceId: String?, maxId: String?)
    {
        guard !isLoading else { return }

        isLoading = true

        itemSource.retrieveItems(sinceId: sinceId, maxId: maxId)
        { [unowned self] (items, error) in
            self.isLoading   = false
            self.errorString = error?.localizedDescription

            if let items = items
            {
                for item in items
                {
                    self.itemRepository.addUnique(item: item)
                }
            }

            self.saveAndUpdate()
        }
    }

    private func saveAndUpdate()
    {
        itemRepository.save()
        items = itemRepository.fetch(limit: fetchLimit)
    }
}
