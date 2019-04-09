//
//  EdgeInsets.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 11/7/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit


///
/// A generic protocol used to describe types that inset content
/// - Remark: For example, UIEdgeInsets and NSDirectionalEdgeInsets
///
public protocol EdgeInsets {
    
    var top: CGFloat { get set }
    var left: CGFloat { get set }
    var bottom: CGFloat { get set }
    var right: CGFloat { get set }
    
}

extension UIEdgeInsets: EdgeInsets {}
extension NSDirectionalEdgeInsets: EdgeInsets {
    
    public var left: CGFloat {
        get {
            return self.leading
        }
        set {
            self.leading = newValue
        }
    }
    
    public var right: CGFloat {
        get {
            return self.trailing
        }
        set {
            self.trailing = newValue
        }
    }
}

extension NSDirectionalEdgeInsets: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.top)
        hasher.combine(self.leading)
        hasher.combine(self.trailing)
        hasher.combine(self.bottom)
    }
    
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }

}

extension UIEdgeInsets: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.top)
        hasher.combine(self.left)
        hasher.combine(self.right)
        hasher.combine(self.bottom)
    }
    
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
}


// MARK: - Operator Overloads

public func *<T: EdgeInsets>(left: T, right: CGFloat) -> T {
    
    var insets = left
    insets.top *= right
    insets.left *= right
    insets.bottom *= right
    insets.right *= right
    
    return insets
}

public func *=<T: EdgeInsets>(left: inout T, right: CGFloat) {
    left = left * right
}
