//
//  ModernGradientContourView.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/24/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A view capable of drawing a gradient within a countour shape bounded by a UIBezierPath
/// - Note: If a specific path does not need to be used to contour the gradient,
///         use ModernGradientView instead
///
open class ModernGradientContourView: ModernContinuousContourView {

    // MARK: - Public
    
    ///
    /// The color used for the gradient; should be backed by a pattern image
    /// - Note: Equivalent to -smoothBackgroundColor
    ///
    public var gradientColor: UIColor? {
        get {
            return super.smoothBackgroundColor
        }
        set {
            super.smoothBackgroundColor = newValue
        }
    }
    
    ///
    /// The contour path used to bound the gradient
    /// - Note: If not specified, the path will be a rounded rect provided by the superclass
    ///
    public var contourPath: CGPath? {
        get {
            return layer.path
        }
        set {
            layer.path = newValue
        }
    }
    
    ///
    /// Convenience function to create the pattern gradient color using an array of colors
    /// - Note: It is somewhat expensive to compute this color, so the result should be cached
    /// - Parameters:
    ///     - colors: The spectrum of colors to unify into the returned single gradient color
    ///     - frame:  The frame (bounds) in which the gradient will be used; likely the bounds of the receiver
    /// - Returns: A single color composed of a pattern image of a gradient of colors
    ///
    public func colorWithGradient(from colors: [UIColor], in frame: CGRect) -> UIColor {
        
        let singleGradientStreakWidth: CGFloat = 1.0
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame.rounded()             // MUST round the rect here
        backgroundGradientLayer.frame.size.width = singleGradientStreakWidth
        backgroundGradientLayer.colors = colors.reversed().CGColors
        
        var size = backgroundGradientLayer.bounds.rounded().size    // MUST round the rect here
        
        // This makes it so that we only compute one downward streak of gradient!
        // This is more performant and takes up much less memory!
        size.width = singleGradientStreakWidth
        
        UIGraphicsBeginImageContext(size)
        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let image = UIColor(patternImage: backgroundColorImage)
        return image
    }

}
