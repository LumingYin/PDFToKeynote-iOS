//
//  ModernFluidButton.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/29/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A button class that is more dynamic, customizable, and fluid
///
public class ModernFluidButton: UIButton {
    
    // MARK: - Settings
    
    @IBInspectable var makeCircular: Bool = false
    @IBInspectable var scalesInteractively: Bool = false
    @IBInspectable var highlightsInteractively: Bool = true

    
    // MARK: - Public
    
    ///
    /// The dynamic background color of the UIButton, suitable to be updated at any time unlike -backgroundColor
    /// - Note: The background color of the receiver set in its storyboard MUST be nil/clear, or this will not work.
    ///
    public var displayedBackgroundColor: UIColor? {
        get {
            if let cgColor = backgroundLayer?.backgroundColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            if (backgroundLayer == nil) {
                backgroundLayer = CAShapeLayer()
                self.layer.addSublayer(backgroundLayer!)
                setNeedsLayout()
            }
            backgroundLayer!.fillColor = newValue?.cgColor
        }
    }
    
    
    // MARK: - UIButton Subclass
    
    override public var isHighlighted: Bool {
        didSet {
            if (scalesInteractively || highlightsInteractively) {
                UIView.animate(withDuration: ModernUIScaleAnimationDuration) {
                    if self.highlightsInteractively {
                        self.alpha = self.isHighlighted ? ModernUILowAlphaLevel : 1.0
                    }
                    if self.scalesInteractively {
                        let scale = ModernUIContentScalingFactor
                        self.transform = self.isHighlighted ? CGAffineTransform(scaleX: scale, y: scale) : .identity
                    }
                }
            }
        }
    }
    
    
    // MARK: - UIView
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer?.zPosition = 0
        backgroundLayer?.frame = self.bounds
        
        if makeCircular {
            self.roundCircularly()
        } else {
            self.backgroundLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
        
        self.layer.masksToBounds = true
    }
    
    
    // MARK: - Private
    
    private var backgroundLayer: CAShapeLayer?

}
