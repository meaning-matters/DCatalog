//
//  ItemSource.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 13/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation

/// Protocol for accessing items in a remote catalog.
protocol ItemSource
{
    /// Gets items from the remote source.
    /// - Parameters:
    ///   - sinceId: If specified, it returns items with an ID greater than (that is, more recent than) the specified ID.
    ///   - maxId: If specified, it returns results with an ID less than (that is, older than) or equal to the specified ID.
    ///   - completion: Block called asynchronously on the main thread passing the results.
    func retrieveItems(sinceId: String?, maxId: String?, completion: @escaping([ItemModel]?, Error?) -> Void)

    /// Adds an item to the remote source.
    /// - Parameters:
    ///   - imageBase64: Base64 encode image.
    ///   - text: Text found in image using OCR.
    ///   - confidence: Level of OCR confidence.
    ///   - completion: Block called asynchronously on the main thread passing the results. The string is the ID
    ///                 assigned by the server to this new item.
    func addItem(imageBase64: String, text: String, confidence: Float, completion: @escaping(String?, Error?) -> Void)

    /// Deletes an item from the remote source.
    /// - Parameters:
    ///   - id: ID of the item to delete.
    ///   - completion: Block called asynchronously on the main thread passing the result.
    func deleteItem(id: String, completion: @escaping(Error?) -> Void)

    /// Delete all items present on the remote source.
    /// - Parameter completion: Block called asynchronously on the main thread passing the result.
    func deleteAllItems(completion: @escaping(Error?) -> Void)
}
