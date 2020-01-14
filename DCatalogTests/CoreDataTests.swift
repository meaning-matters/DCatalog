//
//  CoreDataTests.swift
//  DCatalogTests
//
//  Created by Cornelis van der Bent on 11/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import XCTest
import CoreData
@testable import DCatalog

class CoreDataTests: XCTestCase
{
    var sut: CoreDataItemRepository!

    lazy var managedObjectModel: NSManagedObjectModel =
    {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!

        return managedObjectModel
    }()

    lazy var mockPersistantContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "DCatalog", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores
        { (description, error) in
            // Check if the data store is in memory
            precondition(description.type == NSInMemoryStoreType)

            // Check if creating container wrong
            if let error = error
            {
                fatalError("Create an in-mem coordinator failed: \(error)")
            }
        }

        return container
    }()

    func initStubs()
    {
        func insertItem(id: String, text: String, confidence: Float) -> Item?
        {
            let context = mockPersistantContainer.viewContext
            //let entity = NSEntityDescription.entity(forEntityName: "Item", in: context)!
            //let newItem = Item(entity: entity, insertInto: context)

            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)

            newItem.setValue(id, forKey: "id")
            newItem.setValue("Base64", forKey: "imageBase64")
            newItem.setValue(text, forKey: "text")
            newItem.setValue(confidence, forKey: "confidence")

            return newItem as? Item
        }

        _ = insertItem(id: "0001", text: "item  1", confidence: 0.8)
        _ = insertItem(id: "0002", text: "item  2", confidence: 0.8)
        _ = insertItem(id: "0003", text: "item  3", confidence: 0.8)
        _ = insertItem(id: "0004", text: "item  4", confidence: 0.8)
        _ = insertItem(id: "0005", text: "item  5", confidence: 0.8)
        _ = insertItem(id: "0006", text: "item  6", confidence: 0.8)
        _ = insertItem(id: "0007", text: "item  7", confidence: 0.8)
        _ = insertItem(id: "0008", text: "item  8", confidence: 0.8)
        _ = insertItem(id: "0009", text: "item  9", confidence: 0.8)
        _ = insertItem(id: "0010", text: "item 10", confidence: 0.8)
        _ = insertItem(id: "0011", text: "item 11", confidence: 0.8)
        _ = insertItem(id: "0012", text: "item 12", confidence: 0.8)
        _ = insertItem(id: "0013", text: "item 13", confidence: 0.8)
        _ = insertItem(id: "0014", text: "item 14", confidence: 0.8)
        _ = insertItem(id: "0015", text: "item 15", confidence: 0.8)

        do
        {
            try mockPersistantContainer.viewContext.save()
        }
        catch
        {
            print("Create fakes error: \(error)")
        }
    }

    func flushData()
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let objects = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let object as NSManagedObject in objects
        {
            mockPersistantContainer.viewContext.delete(object)
        }

        try! mockPersistantContainer.viewContext.save()
    }

    override func setUp()
    {
        initStubs()
        sut = CoreDataItemRepository(context: mockPersistantContainer.viewContext)
    }

    override func tearDown()
    {
        flushData()
        sut = nil
    }

    func testAddUnique()
    {
        let item = ItemModel(id: "0000", imageBase64: ".", text: "item 0", confidence: 0.5)
        sut.addUnique(item: item)
        sut.addUnique(item: item)
        sut.addUnique(item: item)

        let request = Item.fetchRequest() as NSFetchRequest<Item>
        request.predicate = NSPredicate(format: "id == %@", "0000")

        XCTAssertNotNil(try mockPersistantContainer.viewContext.fetch(request).first)

        XCTAssertTrue(try mockPersistantContainer.viewContext.fetch(request).count == 1)
    }

    func testDelete()
    {
        sut.deleteItem(with: "0001")

        let request = Item.fetchRequest() as NSFetchRequest<Item>
        request.predicate = NSPredicate(format: "id == %@", "0001")

        XCTAssertNil(try mockPersistantContainer.viewContext.fetch(request).first)
        XCTAssertTrue(sut.fetch(limit: 20).count == 14)
    }

    func testFetch()
    {
        XCTAssertTrue(sut.fetch(limit: 10).count == 10)
        XCTAssertTrue(sut.fetch(limit: 15).count == 15)
        XCTAssertTrue(sut.fetch(limit: 20).count == 15)
    }
}
