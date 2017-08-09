//
//  IndexPath.swift
//  Jazz Time
//
//  Created by Anders Melen on 2/11/16.
//  Copyright © 2016 GMSW. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIView {
    fileprivate struct AssociatedKeys {
        static var DescriptiveName = "indexPath"
    }
    
    var indexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? IndexPath
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as IndexPath?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
