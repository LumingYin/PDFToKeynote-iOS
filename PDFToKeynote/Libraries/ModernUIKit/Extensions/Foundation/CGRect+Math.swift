//
//  CGRect+Math.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/29/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
    
    ///
    /// Returns an equivalent CGRect whose members have been integral rounded
    ///
    public func rounded() -> CGRect {
        return CGRect(x: self.origin.x.rounded(.down),
                      y: self.origin.y.rounded(.down),
                      width: self.size.width.rounded(.up),
                      height: self.size.height.rounded(.up))
    }
    
    ///
    /// Rounds each member of the receiver to an integral value
    ///
    public mutating func round() {
        self.origin.x.round(.down)
        self.origin.y.round(.down)
        self.size.width.round(.up)
        self.size.height.round(.up)
    }
    
}
