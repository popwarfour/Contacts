//
//  ContactParameterTableViewCell.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

class ContactParameterTableViewCell: UITableViewCell, Cellable {
    
    typealias DateInputClosureType = (Contact.Parameter, Date?) -> Void
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    
    private var parameter: Contact.Parameter?
    private var dateInputClosure: DateInputClosureType?
    
    // MARK: - ContactCellable
    /// Returns the cell's reuse identifier.
    static func reuseID() -> String {
        return TABLE_VIEW_CELL_CONTACT_PARAMETER_IDENTIFIER
    }
    
    // MARK: - Configuration
    /// Configure the cell with a Optional.String
    func configure(parameter: Contact.Parameter,
                   string: String?,
                   image: UIImage?,
                   indexPath: IndexPath) {
        
        self.parameter = parameter
        
        // Configure Image
        self.configureImageView(image: image)
        
        // Configure Value
        if let string = string {
            self.configureValue(parameter: parameter,
                                indexPath: indexPath,
                                value: string)
        } else {
            self.configureValue(parameter: parameter,
                                indexPath: indexPath,
                                value: "")
        }
        
    }
    
    /// Configure the cell with a Optional.Date
    func configure(parameter: Contact.Parameter,
                   date: Date?,
                   image: UIImage?,
                   indexPath: IndexPath,
                   dateInputClosure: @escaping DateInputClosureType) {
     
        self.parameter = parameter
        self.dateInputClosure = dateInputClosure
        
        // Configure Image
        self.configureImageView(image: image)
        
        // Configure Value
        if let date = date {
            self.configureValue(parameter: parameter,
                                indexPath: indexPath,
                                value: date.toString(dateStyle: .short, timeStyle: .none))
        } else {
            self.configureValue(parameter: parameter,
                                indexPath: indexPath,
                                value: "")
        }
    }
    
    /// Configures the value `UITextField`
    private func configureValue(parameter: Contact.Parameter,
                                indexPath: IndexPath,
                                value: String) {
        
        self.inputTextField.indexPath = indexPath
        self.inputTextField.placeholder = parameter.rawValue
        self.inputTextField.text = value
    }
    
    /// Configures the label `UIImageView`
    private func configureImageView(image: UIImage?) {
        guard let image = image else {
            self.iconImageView.alpha = 0.0
            return
        }
        
        self.iconImageView.alpha = 0.6
        self.iconImageView.image = image
        
    }
    
    
}
