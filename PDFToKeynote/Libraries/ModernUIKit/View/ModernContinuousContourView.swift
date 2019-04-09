//
//  ModernContinuousContourView.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/24/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A view that smoothly and performantly renders the specified corner contour
/// Available to be subclassed to add this behavior to other views
///
open class ModernContinuousContourView: UIView {
    
    // MARK: - Public
    
    /// The smooth corner radius to be used
    public var smoothCornerRadius: CGFloat
    
    /// The option set of corners to round
    public var roundedCorners: UIRectCorner
    
    ///
    /// The color used to fill the smooth contour
    /// - Note: Sets the background color of the receiver to clear when set to a non-nil value
    ///
    public var smoothBackgroundColor: UIColor? {
        get {
            if let fillColor = self.layer.fillColor {
                return UIColor(cgColor: fillColor)
            }
            return nil
        }
        set {
            self.layer.fillColor = newValue?.cgColor
            if newValue != nil {
                self.backgroundColor = .clear
            }
        }
    }
    
    
    // MARK: - Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        self.smoothCornerRadius = 0.0
        self.roundedCorners = .allCorners
        
        super.init(coder: aDecoder)
        self.clipsToBounds = false
    }
    
    
    // MARK: - UIView
    
    override open class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override open var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        /*
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = window!.screen.scale
         */
        
        let cornerRadii = CGSize(width: smoothCornerRadius, height: smoothCornerRadius)
        let smoothBoundingPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: cornerRadii)
        self.layer.path = smoothBoundingPath.cgPath
    }
    
}
