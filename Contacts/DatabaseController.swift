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
                        "Contact": [0xd1c6f53512836243, 0x30f7b02bc0a80c9c, 0x753669045e335bb9, 0x5c22b2853d38f181]
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
