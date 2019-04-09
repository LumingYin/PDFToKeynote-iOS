//
//  UIView+Core.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/23/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIView {
    
    ///
    /// The corner radius of the receiving view
    ///
    public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            let mask = newValue > 0 && (self.layer.shadowColor == nil)
            self.layer.masksToBounds = mask
            self.clipsToBounds = mask
        }
    }
    
    ///
    /// Performantly add a shadow around the receiver
    /// - Note: Uses the -cornerRadius property to set a rounded bounding path for the shadow if necessary
    ///
    public func shadow(withRadius shadowRadius: CGFloat = 9) {
        let layer = self.layer
        layer.masksToBounds = false;
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 1.0
        
        if let _ = layer as? CAShapeLayer {
//            layer.shadowPath = shapeLayer.path
        } else {
            layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath // Set a shadow path to improve performance
        }
    }
    
    ///
    /// Set the receiver's corner radii such that it becomes circular
    ///
    public func roundCircularly() {
        self.cornerRadius = (self.bounds.size.width / 2.0).rounded(.up)
    }
    
    ///
    /// Add a horizontal shake animation to the receiver
    ///
    public func shake(repeating repeatCount: Int) {
        let animation = CABasicAnimation(keyPath:  "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = Float(repeatCount)
        animation.duration = 0.08
        animation.autoreverses = true
        animation.byValue = 9 //how much it moves
        self.layer.add(animation, forKey: "position")
    }
    
    ///
    /// Add a dashed line border to the given layer using the geometric properties of the receiver
    /// - Note: This method sets the fillColor property of the layer to clear. Should be called in -layoutSubviews.
    ///
    public func addDashedLineBorder(to layer: CAShapeLayer, width: CGFloat = 2.0) {
        let frame = self.bounds.inset(by: UIEdgeInsets(constant: width / 2.0))
        let path = UIBezierPath(roundedRect: frame, cornerRadius: self.cornerRadius)
        layer.path = path.cgPath
        layer.strokeColor = UIColor.darkGray.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineDashPattern = [8, 4] as [NSNumber]
        layer.lineJoin = .round
        layer.lineWidth = width
        layer.frame = self.bounds
    }
    
}
