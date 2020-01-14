//
//  ItemRepository.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 13/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation

/// Protocol for storage of items.
protocol ItemRepository
{
    /// Stores an item if it's not yet in storage.
    ///
    /// Uniqueness is determined solely by comparing `id`. If the item's ID is found to be already in the repository,
    /// this function will do nothing.
    ///
    /// - Parameter item: The item to store.
    func addUnique(item: ItemModel)

    /// Deletes the specified item from storage.
    /// - Parameter id: The ID of the item to delete.
    func deleteItem(with id: String)

    /// Fetches items from storage.
    /// - Parameter limit: Maximum number of items returned.
    /// - Returns: Array with fetched items as `ItemModel` objects.
    func fetch(limit: Int) -> [ItemModel]

    /// Saves changes to disk.
    func save()
}
