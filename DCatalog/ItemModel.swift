//
//  ItemModel.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 12/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation

/// Public item class that acts as a mirror of hidden Core Data class `Item`.
///
/// The Core Data class `Item` is not used because `NSManagedObjects` are not generic and should not be used in
/// protocols.
class ItemModel : NSObject, Codable
{
    /// Unique ID identifying this item.
    let id: String

    /// Base64-encoded image.
    let imageBase64: String

    /// Text found in image using OCR.
    let text: String

    /// OCR confidence of found text.
    let confidence: Float

    /// Translates the JSON keys received from the server into more readable/proper names.
    enum CodingKeys : String, CodingKey
    {
        case id = "_id"
        case imageBase64 = "img"
        case text
        case confidence
    }

    /// Creates an item from separate values.
    /// - Parameters:
    ///   - id: Unique ID identifying this item.
    ///   - imageBase64: Base64-encoded image.
    ///   - text: Text found in image using OCR.
    ///   - confidence: OCR confidence of found text.
    init(id: String, imageBase64: String, text: String, confidence: Float)
    {
        self.id = id
        self.imageBase64 = imageBase64
        self.text = text
        self.confidence = confidence

        super.init()
    }

    /// Creates an item from Core Data object.
    /// - Parameter item: Core Data item.
    init(item: Item)
    {
        // `NSManagedObject` properties are optional. In the database model however, none are optional. Therefore the
        // force unwrappings below won't cause trouble.
        self.id = item.id!
        self.imageBase64 = item.imageBase64!
        self.text = item.text!
        self.confidence = item.confidence
    }
}
