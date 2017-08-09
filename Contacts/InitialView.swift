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
    func configure(fontSize: CGFloat,
                   color: UIColor,
                   character: Character?) {
        
        self.container.backgroundColor = color
        self.container.borderColor = InitialView.borderColor(color: color)
        
        self.label.font = UIFont(name: self.label.font.fontName, size: fontSize)
        
        if let character = character {
            self.label.text = String(character).uppercased()
        } else{
            self.label.text = "?"
        }
        
    }
    
    static func borderColor(color: UIColor) -> UIColor {
        
        if let red = color.cgColor.components?[0],
            let green = color.cgColor.components?[1],
            let blue = color.cgColor.components?[2] {
            
            
            return UIColor(colorLiteralRed: min(Float(red + 0.1), 1.0),
                           green: min(Float(green + 0.1), 1.0),
                           blue: min(Float(blue + 0.1), 1.0),
                           alpha: 1.0)
            
        }
        
        return color
    
        
    }

}
