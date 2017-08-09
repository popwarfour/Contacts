//
//  InitalView.swift
//  Contacts
//
//  Created by Anders Melen on 8/8/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

class InitialView: UIView {

    @IBOutlet weak var container: Designable!
    @IBOutlet weak var label: UILabel!
    
    
    // MARK: - Configuration
    func configure(character: Character?) {
        
        if let character = character {
            self.label.text = String(character)
        } else{
            self.label.text = ""
        }
        
    }

}
