//
//  DatabaseController.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import Foundation
import CoreStore

class DatabaseController {
    
    static let shared = DatabaseController()
    
    lazy var contactStack: DataStack = {
       
        do {
            
            let stack = DataStack(
                
                CoreStoreSchema(modelVersion: "V1",
                                entities: [
                                    Entity<Contact>("Contact")
                    ],versionLock: [
                        "Contact": [0x19a89cef6f3f1e3d, 0xfbd50d0e77b30407, 0xf4eba3a2f5025a2a, 0xabf6dd2ccdb27766]
                    ])
                
            )
            
            try stack.addStorageAndWait(SQLiteStore(fileName: "Database.sqlite"))
            return stack
            
        } catch let error {
            
            fatalError("Failed to setup CoreStore storage for \(error)")
            
        }
        
    }()
    
    /// Perform an asynchronous database transaction. Perform the database operation in the `transactionClosure` and handle the result in the `completionClosure`. Calling a transaction via this method guarentees the database has been configuration.
    func perform<T>(transactionClosure: @escaping (AsynchronousDataTransaction) throws -> T,
                    completionClosure: @escaping (AsynchronousDataTransaction.Result<T>) -> Void) {
        
        self.contactStack.perform(asynchronous: transactionClosure,
                                  completion: completionClosure)
        
    }
    
}
