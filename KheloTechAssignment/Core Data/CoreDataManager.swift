//
//  CoreDataManager.swift
//  KheloTechAssignment
//
//  Created by Muskan Gupta on 01/10/24.
//

import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager() // will live forever as long as your app is alive, its properties will to
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SportEntity")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed: \(error)")
            }
        }
        return container
    }()
    
    
    
}
