//
//  ContactTableViewCell.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit
import PureLayout

class ContactTableViewCell: UITableViewCell, Cellable {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var initialContainer: UIView!
    
    var initialView: InitialView?
    
    // MARK: - ContactCellable
    /// Returns the cells reuse identifier.
    static func reuseID() -> String {
        return TABLE_VIEW_CELL_CONTACT_IDENTIFIER
    }
    
    // MARK: - Configuration
    /// Configures the cell with a `Contact` record.
    func configure(contact: Contact) {
        
        self.nameLabel.text = "\(contact.firstName) \(contact.lastName)"
        self.configureInitialView(contact: contact)
    }
    
    // MARK: - Subview Configuration
    
    private func configureInitialView(contact: Contact) {
        
        if self.initialView == nil {
            
            self.initialView = InitialView.viewByTypeFromNibNamed(nibName: NIB_INITIAL_VIEWS)
            self.initialContainer.addSubview(self.initialView!)
            self.initialView?.autoPinEdgesToSuperviewEdges()
            
        }
        
        let character = contact.firstName.characters.first
        self.initialView?.configure(character: character)
        
    }
    
}
