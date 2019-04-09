//
//  ModernGradientView.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 10/1/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

open class ModernGradientView: UIView {

    // MARK: - Public
    
    open var gradientColors: [UIColor] {
        get {
            return (self.layer.colors as? [CGColor] ?? []).UIColors
        }
        set {
            self.layer.colors = newValue.CGColors
        }
    }
    
    open var startPoint: CGPoint {
        get {
            return self.layer.startPoint
        }
        set {
            self.layer.startPoint = newValue
        }
    }
    
    open var endPoint: CGPoint {
        get {
            return self.layer.endPoint
        }
        set {
            self.layer.endPoint = newValue
        }
    }
    
    
    // MARK: - UIView Subclass
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override open var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
    
}
