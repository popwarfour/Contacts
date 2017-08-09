//
//  Designable.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

/// This class allows you to style your views directly from Interface Builder without k/v pairs.
@IBDesignable class Designable: UIView {
    
    /// Force Rounded
    @IBInspectable var rounded: Bool = false
    
    /// Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    
    // MARK: - Layout Sub Views
    /// Fix corner radius if too big
    override func layoutSubviews() {
        
        if self.rounded == true {
            
            let radius = min(self.frame.height, self.frame.width) / 2.0
            self.cornerRadius = radius
            
        }
        
        super.layoutSubviews()
        
    }
}
