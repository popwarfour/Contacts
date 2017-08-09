//
//  UIView+Methods.swift
//  Contacts
//
//  Created by Anders Melen on 8/8/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

extension UIView {
    
    static func viewByTypeFromNibNamed<T>(nibName: String) -> T? {
        
        let nibContents = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        for tempView in nibContents! {
            if let foundView = tempView as? T {
                return foundView
            }
        }

        return nil
    }
}
