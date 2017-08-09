//
//  AppDelegate.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit
import CoreStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = UIApplication.shared.delegate as! AppDelegate
    
    var window: UIWindow?

    var contactDelegate: ContactUpdateDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Create sample contacts on first launch
        let firstLaunch = UserDefaults.standard.object(forKey: "HAS_LAUNCHED") as? Bool
        if firstLaunch == nil {
            
            UserDefaults.standard.set(true, forKey: "HAS_LAUNCHED")
            UserDefaults.standard.synchronize()
            
            self.createSampleContacts()
        }
        
        return true
    }

    /// Creates sample `Contact` objects
    private func createSampleContacts() {
        
        let saveClosure: (Bool, AsynchronousDataTransaction.Result<Contact>) -> Void = { notifyDelegate, result in
            
            if notifyDelegate {
                self.contactDelegate?.shouldReloadContacts()
            }
            
            switch result {
                
            case .success(_):
                break
                
            case .failure(_):
                assert(false,
                       "Failed to create sample `Contact`s")
                break
                
            }
            
        }

        do {

            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Anders",
                                                              Contact.Parameter.lastName: "Melen"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Albert",
                                                              Contact.Parameter.lastName: "Einstein"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Jane",
                                                              Contact.Parameter.lastName: "Goodall"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Enrico",
                                                              Contact.Parameter.lastName: "Fermi"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Flossie",
                                                              Contact.Parameter.lastName: "Wong-Staal"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Lise",
                                                              Contact.Parameter.lastName: "Meitner"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Niels",
                                                              Contact.Parameter.lastName: "Bohr"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Werner",
                                                              Contact.Parameter.lastName: "Heisenberg"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Max",
                                                              Contact.Parameter.lastName: "Planck"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(false, result) })
            
            try Contact.create(contactDTO: Contact.DTO(data: [Contact.Parameter.firstName: "Isaac",
                                                              Contact.Parameter.lastName: "Newton"],
                                                       color: Contact.DTO.randomColor()),
                               completionClosure: { result in saveClosure(true, result) })
        
        } catch let error {
                
            assert(false,
                   "Failed to create `Contact`. \(error)")
                
        }
        
    }
    
}

