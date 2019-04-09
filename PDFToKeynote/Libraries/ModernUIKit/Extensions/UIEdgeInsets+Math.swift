//
//  UIEdgeInsets+Math.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 10/19/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    public init(constant inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
}
