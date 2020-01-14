//
//  ItemCell.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 13/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import UIKit

/// Cell showing all item info.
class ItemCell : UITableViewCell
{
    static let nibName = "ItemCell"
    static let identifier = "ItemCell"

    @IBOutlet private var idLabel: UILabel!
    @IBOutlet private var itemImageView: UIImageView! // Had to prepend `item` because already in `UITableViewCell`.
    @IBOutlet private var itemTextLabel: UILabel! // Had to prepend `item` because already in `UITableViewCell`.
    @IBOutlet private var confidenceLabel: UILabel!

    override func layoutSubviews()
    {
        super.layoutSubviews()

        itemImageView.layer.borderWidth = 2
        itemImageView.layer.borderColor = UIColor.lightGray.cgColor
        itemImageView.layer.cornerRadius = 8
    }

    var item: ItemModel!
    {
        didSet
        {
            if let imageData = Data(base64Encoded: item.imageBase64)
            {
                itemImageView.image = UIImage(data: imageData)
            }

            idLabel.text = "ID: \(item.id)"
            itemTextLabel.text = "Text: \(item.text)"
            confidenceLabel.text = "Confidence: \(item.confidence)"
        }
    }
}
