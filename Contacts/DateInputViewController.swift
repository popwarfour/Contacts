//
//  DateInputViewController.swift
//  Contacts
//
//  Created by Anders Melen on 8/7/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

class DateInputViewController: UIViewController {

    typealias DateSaveClosureType = (Date?) -> Void
    
    @IBOutlet weak var datePicker: UIDatePicker!

    var saveClosure: DateSaveClosureType?
    
    // MARK: - Configuration
    /// Configures the view with a `Date?`
    func configure(date: Date?,
                   saveClosure: @escaping DateSaveClosureType) {
        
        if let date = date {
            self.datePicker.date = date
        }
        
        self.saveClosure = saveClosure
        
    }
    
    // MARK: - Button Actions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.saveClosure?(nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        self.saveClosure?(self.datePicker.date)
    }
}
