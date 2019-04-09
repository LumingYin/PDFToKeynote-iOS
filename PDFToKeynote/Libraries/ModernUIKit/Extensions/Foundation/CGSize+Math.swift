//
//  CGSize+Math.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/7/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import CoreGraphics

extension CGSize {
    
    ///
    /// Whether or not the size and the receiver have matching dimensions regardless of orientation
    /// Returns two if the two sizes are equal or if self.width == size.height && self.height == size.width
    ///
    public func isCongruent(to size: CGSize) -> Bool {
        return (self == size) || (self.width == size.height && self.height == size.width)
    }
    
}


// MARK: - Hashable

extension CGSize: Hashable {
    
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.width)
        hasher.combine(self.height)
    }
    
}
