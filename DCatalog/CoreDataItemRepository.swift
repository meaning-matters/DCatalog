//
//  CoreDataItemRepository.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 13/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation
import CoreData

/// Core Data implementation of the repository.
class CoreDataItemRepository : ItemRepository
{
    private var context: NSManagedObjectContext

    /// Creates a repository object.
    /// - Parameter context: The context.
    init(context: NSManagedObjectContext)
    {
        self.context = context
    }

    // MARK: - ItemRepository

    func addUnique(item: ItemModel)
    {
        if findItem(with: item.id) == nil
        {
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as! Item

            newItem.id = item.id
            newItem.imageBase64 = item.imageBase64
            newItem.text = item.text
            newItem.confidence = item.confidence
        }
    }

    func deleteItem(with id: String)
    {
        if let item = findItem(with: id)
        {
            context.delete(item)
        }
    }

    func fetch(limit: Int) -> [ItemModel]
    {
        do
        {
            let fetchRequest: NSFetchRequest = Item.fetchRequest()
            fetchRequest.fetchLimit = limit
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]

            return try context.fetch(fetchRequest).map
            {
                ItemModel(id: $0.id!, imageBase64: $0.imageBase64!, text: $0.text!, confidence: $0.confidence)
            }
        }
        catch let error
        {
            // TODO: Handle properly.
            print("Fetch failed: \(error.localizedDescription)")

            return []
        }
    }

    func save()
    {
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch let error
            {
                // TODO: Handle properly.
                print("Save failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Helpers

    public static func entityDescription(context: NSManagedObjectContext) -> NSEntityDescription
    {
        return NSEntityDescription.entity(forEntityName: "Item", in: context)!
    }

    private func findItem(with id: String) -> Item?
    {
        let request = Item.fetchRequest() as NSFetchRequest<Item>
        request.predicate = NSPredicate(format: "id == %@", id)
        do
        {
             return try self.context.fetch(request).first
        }
        catch let error
        {
            // TODO: Handle properly.
            print("Fetch failed: \(error.localizedDescription)")

            return nil
        }
    }
}
