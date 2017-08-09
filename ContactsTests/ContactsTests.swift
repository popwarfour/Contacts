//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import XCTest

class ContactsTests: XCTestCase {

    
    // MARK: - Database
    /// Provides a finite state machine for performing our unit tests in the correct order
    private enum DatabaseTestStage {
        
        case setup
        case insertAndUpdate
        case fetchSearchTerm
        case delete
        
        static let start = DatabaseTestStage.setup
        
        /// Fetch the next `DatabaseTestStage` to test
        func nextStage() -> DatabaseTestStage? {
            
            switch self {
                
            case .setup:
                return DatabaseTestStage.insertAndUpdate
                
            case .insertAndUpdate:
                return DatabaseTestStage.fetchSearchTerm
            
            case .fetchSearchTerm:
                return DatabaseTestStage.delete
                
            case .delete:
                return nil
                
            }
            
        }
        
    }
    
    /// Tests the creation of the CoreData database and all basic CRUD functionality
    func testDatabase() {
    
        let expectation = self.expectation(description: "async database tests")
        
        let stage = DatabaseTestStage.start
        self._testDatabaseStages(databaseStage: stage) {
            expectation.fulfill()
        }
    
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    /// Run tests for all stages
    private func _testDatabaseStages(databaseStage: DatabaseTestStage,
                                     completion: @escaping () -> Void) {
        
        self._testStage(stage: databaseStage) { 
            if let nextStage = databaseStage.nextStage() {
                self._testDatabaseStages(databaseStage: nextStage,
                                         completion: completion)
            } else {
                completion()
            }
        }

    }
    
    /// Run tests for stage
    private func _testStage(stage: DatabaseTestStage,
                            completion: @escaping () -> Void) {
        
        switch stage {
            
        case .setup:
            self._clearDatabase(completion: completion)
            break
            
        case .insertAndUpdate:
            self._testDatabaseInsertAndUpdate(completion: completion)
            break
            
        case .fetchSearchTerm:
            self._testDatabaseFetchBySearchTerm(completion: completion)
            break

        case .delete:
            self._testDatabaseDelete(completion: completion)
            break
            
        }
        
    }
    
    /// Clears the entire database
    private func _clearDatabase(completion: @escaping () -> Void) {
        
        Contact.delete { result in
            
            switch result {
                
            case .success(_):
                completion()
                break
                
            case .failure(let error):
                XCTFail("Failed to setup by deleting existing records \(error)")
                break
                
            }
        }
        
    }
    
    
    // MARK: Crud
    /// Tests searching
    private func _testDatabaseFetchBySearchTerm(completion: @escaping () -> Void) {
        
        guard let contacts = Contact.fetch(searchTerm: "And") else {
            XCTFail("Expected contacts to not be nil")
            return
        }
        
        guard contacts.count == 1 else {
            XCTFail("Expected there to be one contact")
            return
        }
        
        let contact = contacts.first!
        
        guard contact.firstName == "Anders-Changed" && contact.lastName == "Melen-Changed" else {
            XCTFail("Search term returned wrong contact object")
            return
        }
        
        completion()
    }
    
    /// Tests inserting/updating a `Contact` object
    private func _testDatabaseInsertAndUpdate(completion: @escaping () -> Void) {
        
        let updateClosure: (Contact) -> Void = { contact in
            
            do {
                
                try contact.update(updateClosure: { transactionContact in

                    transactionContact.firstName = "Anders-Changed"
                    transactionContact.lastName = "Melen-Changed"

                }, completionClosure: { result in
                    
                    switch result {
                        
                    case .success(_):
                        completion()
                        break
                        
                    case .failure(let error):
                        XCTFail("Failed to insert \(error)")
                        break
                        
                    }
                    
                })

            } catch let error {
                XCTFail("Failed to insert \(error)")
            }
        
        }
        
        
        do {
            
            // Create a record to update
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "",
                                                              Contact.Parameter.lastName: ""],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in
                                
                                switch result {
                                    
                                case .success(let contact):
                                    updateClosure(contact)
                                    break
                                    
                                case .failure(let error):
                                    XCTFail("Failed to insert \(error)")
                                    break
                                    
                                }
            })
            
        } catch let error {
            XCTFail("Failed to insert \(error)")
        }
        
    }
    
    private func _testDatabaseDelete(completion: @escaping () -> Void) {
        
        let firstNamePredicate = NSPredicate(format: "firstName == %@", "Anders")
        let lastNamePredicate = NSPredicate(format: "lastName == %@", "Melen")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [firstNamePredicate,
                                                                            lastNamePredicate])
        
        let deletionFetchCheckClosure = {
            
            guard Contact.fetch(predicate: predicate)?.count == 0 else {
                XCTFail("Expected contacts to be nil after deletion")
                return
            }
            
            completion()
            
        }
        
        
        Contact.delete(predicate: predicate,
                       completionClosure: { result in
                    
                        switch result {
                                
                        case .success(_):
                            deletionFetchCheckClosure()
                            break
                                
                        case .failure(let error):
                            XCTFail("Failed to delete \(error)")
                            break
                                
                        }
                            
        })
        
    }
    
}
