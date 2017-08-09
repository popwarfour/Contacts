//
//  Contact.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import Foundation
import CoreStore


class Contact: CoreStoreObject {

    enum ContactError: Error {
    
        case parametersRequired([Contact.Parameter])
    
    }
    
    class DTO {
        
        typealias DataType = [Contact.Parameter : Any?]
        var data: DataType
        let color: UIColor
        
        init(data: DataType = [:],
             color: UIColor = DTO.randomColor()) {
            
            self.data = data
            self.color = color
            
        }
        
        convenience init(contact: Contact) {
            
            var data = DataType()
            for parameter in Contact.Parameter.all() {
                
                let value = parameter.getValue(contact: contact)
                data[parameter] = value
                
            }
            
            self.init(data: data,
                      color: contact.color)
        }
        
        // MARK: - Color
        static func randomColor() -> UIColor {
            
            let random = arc4random() % 6
            
            switch random {
                
            case 0:
                return UIColor(colorLiteralRed: 184.0/255.0, green: 255.0/255.0, blue: 204.0/255.0, alpha: 1.0)
                
            case 1:
                return UIColor(colorLiteralRed: 255.0/255.0, green: 202.0/255.0, blue: 185.0/255.0, alpha: 1.0)
                
            case 2:
                return UIColor(colorLiteralRed: 239.0/255.0, green: 255.0/255.0, blue: 191.0/255.0, alpha: 1.0)
                
            case 3:
                return UIColor(colorLiteralRed: 255.0/255.0, green: 221.0/255.0, blue: 251.0/255.0, alpha: 1.0)
                
            case 4:
                return UIColor(colorLiteralRed: 217.0/255.0, green: 228.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                
            default:
                return UIColor(colorLiteralRed: 204.0/255.0, green: 255.0/255.0, blue: 247.0/255.0, alpha: 1.0)
                
            }
            
        }
        
    }
    
    // MARK: - Public Model
    enum Parameter: String {
        
        enum ParameterType {
            case required
            case optional
        }
        
        case firstName = "First"
        case lastName = "Last"
        case dateOfBirth = "Birth Date"
        case zipCode = "Zip"
        case phoneNumber = "Phone"
        
        func parameterType() -> ParameterType {
            
            switch self {
                
            case .firstName, .lastName:
                return .required
                
            case .dateOfBirth, .zipCode, .phoneNumber:
                return .optional
                
            }
            
        }
        
        func getValue(contact: Contact) -> Any? {
            
            switch self {
                
            case .firstName:
                return contact.firstName
            case .lastName:
                return contact.lastName
            case .dateOfBirth:
                return contact.dateOfBirth
            case .zipCode:
                return contact.zipCode
            case .phoneNumber:
                return contact.phoneNumber
                
            }
            
        }
        
        func setValue(contact: Contact,
                      value: Any?) throws {
            
            switch self {
                
            case .firstName:
                guard let value = value else {
                    throw ContactError.parametersRequired([self])
                }
                guard let string = value as? String else {
                    assert(false,
                           "Expected `String` for \(self)")
                    break
                }
                
                contact.firstName = string
                break
                
            case .lastName:
                guard let value = value else {
                    throw ContactError.parametersRequired([self])
                }
                guard let string = value as? String else {
                    assert(false,
                           "Expected `String` for \(self)")
                    break
                }
                
                contact.lastName = string
                break
            
            case .dateOfBirth:
                guard value != nil else {
                    contact.dateOfBirth = nil
                    break
                }
                
                guard let date = value as? Date else {
                    assert(false,
                           "Expected `Date?` for \(self)")
                    break
                }
                
                contact.dateOfBirth = date
                break

            case .zipCode:
                guard value != nil else {
                    contact.zipCode = nil
                    break
                }
                
                guard let string = value as? String else {
                    assert(false,
                           "Expected `String?` for \(self)")
                    break
                }
                
                contact.zipCode = string
                break
                
            case .phoneNumber:
                guard value != nil else {
                    contact.phoneNumber = nil
                    break
                }
                
                guard let string = value as? String else {
                    assert(false,
                           "Expected `String?` for \(self)")
                    break
                }
                
                contact.phoneNumber = string
                break
            
            }
            
        }
        
        static func all() -> [Contact.Parameter] {
            return [.firstName,
                    .lastName,
                    .dateOfBirth,
                    .zipCode,
                    .phoneNumber]
        }
        
    }
    
    // MARK: - Private Model
    private let _firstName = Value.Required<String>("firstName")
    private let _lastName = Value.Required<String>("lastName")
    private let _color = Value.Required<Data>("color")
    private let _dateOfBirth = Value.Optional<Date>("dateOfBirth")
    private let _zipCode = Value.Optional<String>("zipCode")
    private let _phoneNumber = Value.Optional<String>("phoneNumber")
    
    // MARK: Get/Set
    var firstName: String {
        get {
            return self._firstName.value
        }
        set {
            self._firstName.value = newValue
        }
    }
    
    var lastName: String {
        get {
            return self._lastName.value
        }
        set {
            self._lastName.value = newValue
        }
    }
    
    var color: UIColor {
        get {
            guard let color = NSKeyedUnarchiver.unarchiveObject(with: self._color.value) as? UIColor else {
                
                assert(false,
                       "Expected `Data` to unarchive into `UIColor`")
                return Contact.DTO.randomColor()
                
            }
            
            return color
        }
        set {
            self._color.value = NSKeyedArchiver.archivedData(withRootObject: newValue)
        }
    }
    
    var dateOfBirth: Date? {
        get {
            return self._dateOfBirth.value
        }
        set {
            self._dateOfBirth.value = newValue
        }
    }
    
    var zipCode: String? {
        get {
            return self._zipCode.value
        }
        set {
            self._zipCode.value = newValue
        }
    }
    
    var phoneNumber: String? {
        get {
            return self._phoneNumber.value
        }
        set {
            self._phoneNumber.value = newValue
        }
    }
    
    // MARK: - Crud
    // MARK: Create
    /// Creates a new `Contact` record.
    static func create(contactDTO: Contact.DTO,
                       completionClosure: @escaping (AsynchronousDataTransaction.Result<Contact>) -> Void) throws {

        DatabaseController.shared.perform(transactionClosure: { transaction -> Contact in
            
            let contact = try Contact.create(transaction: transaction,
                                             contactDTO: contactDTO)
            return contact
            
        }, completionClosure: completionClosure)
        
    }
    
    // MARK: Fetch
    /// Fetch `Contact`s whose first OR last names CONTAIN the search term
    static func fetch(searchTerm: String) -> [Contact]? {
        
        let firstNamePredicate = NSPredicate(format: "firstName contains[cd] %@", searchTerm)
        let lastNamePredicate = NSPredicate(format: "lastName contains[cd] %@", searchTerm)
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [firstNamePredicate,
                                                                           lastNamePredicate])

        let contacts = DatabaseController.shared.contactStack.fetchAll(From<Contact>(),
                                                                       Where(predicate))
        return contacts
        
    }
    
    /// Fetch `Contact`s whose first AND last names match the provided
    static func fetch(firstName: String,
                      lastName: String) -> [Contact]? {
        
        let firstNamePredicate = NSPredicate(format: "firstName == %@", firstName)
        let lastNamePredicate = NSPredicate(format: "lastName == %@", lastName)
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [firstNamePredicate,
                                                                           lastNamePredicate])
        
        return Contact.fetch(predicate: predicate)
        
    }
    
    /// Fetch `Contact`s who match the provided `NSPredicate`
    static func fetch(predicate: NSPredicate = NSPredicate(value: true)) -> [Contact]? {
        
        let contacts = DatabaseController.shared.contactStack.fetchAll(From<Contact>(),
                                                                       Where(predicate))
        return contacts
            
    }
    
    // MARK: Update
    /// Possible update errors
    enum UpdateError: Error {
        case objectDoesNotExist
    }
    
    /// Updates an existing `Contact` object. The object must already exist!
    func update(updateClosure: @escaping (inout Contact) throws -> Void,
                completionClosure: @escaping (AsynchronousDataTransaction.Result<Contact>) -> Void) throws {
        
        DatabaseController.shared.perform(transactionClosure: { transaction -> Contact in
            
            guard var transactionContact = transaction.edit(self) else {
                throw UpdateError.objectDoesNotExist
            }
            
            try updateClosure(&transactionContact)
            return transactionContact
            
        }, completionClosure: completionClosure)
        
    }
    
    // MARK: Delete
    /// Deletes any `Contact`s matching the `NSPredicate`
    static func delete(predicate: NSPredicate = NSPredicate(value: true),
                       completionClosure: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void) {
        
        guard let contacts = Contact.fetch() else {
            completionClosure(AsynchronousDataTransaction.Result<Void>.success(userInfo: ()))
            return
        }
        
        Contact.delete(contacts: contacts,
                       completionClosure: completionClosure)
        
    }
    
    /// Deletes `Contact`s from the database
    static func delete(contacts: [Contact],
                       completionClosure: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void) {
        
        DatabaseController.shared.perform(transactionClosure: { transaction -> Void in
            
            transaction.delete(contacts)
            
        }, completionClosure: completionClosure)
        
    }
    
    
    /// Deletes the `Contact` from the database
    func dalete(completionClosure: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void) {
        
        DatabaseController.shared.perform(transactionClosure: { transaction -> Void in
            
            transaction.delete(self)
            
        }, completionClosure: completionClosure)
        
    }
    
    // MARK: - Constructor
    /// Creates a `Contact` record given a `BaseDataTransaction`.
    private static func create(transaction: BaseDataTransaction,
                               contactDTO: Contact.DTO) throws -> Contact {
        
        // Create record with database transaction
        let contact = transaction.create(Into(Contact.self))
        
        // Configure parmaters
        try contact.configure(contactDTO: contactDTO)
        
        return contact
        
    }

    // MARK: Configuration
    /// Configures a `Contact` from a `Contact.DTO`
    func configure(contactDTO: Contact.DTO) throws {
        
        // Validate
        try Contact.validate(contactDTO: contactDTO)
        
        // Set Values
        for (parameter, value) in contactDTO.data {
            
            try parameter.setValue(contact: self, value: value)
            
        }
        
        self.color = contactDTO.color
        
    }
    
    static func validate(contactDTO: Contact.DTO) throws {
        
        // Check for missing required parameters
        var missingRequired = [Parameter]()
        for parameter in Contact.Parameter.all() {
            
            if parameter.parameterType() == .required {
                if contactDTO.data[parameter] == nil {
                    missingRequired.append(parameter)
                }
            }
            
        }
        
        guard missingRequired.count == 0 else {
            throw ContactError.parametersRequired(missingRequired)
        }

        
    }
    
}
