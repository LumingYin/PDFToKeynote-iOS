//
//  UIColor+Core.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/6/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - INITIALIZATION
    
    public convenience init(fullRed: CGFloat, fullGreen: CGFloat, fullBlue: CGFloat) {
        self.init(red: (fullRed / 255.0), green: (fullGreen / 255.0), blue: (fullBlue / 255.0), alpha: 1.0)
    }
    
    public convenience init(hex: UInt32) {
        let red   = CGFloat((hex & 0xFF0000) >> 16)
        let green = CGFloat((hex & 0x00FF00) >>  8)
        let blue  = CGFloat((hex & 0x0000FF) >>  0)
        self.init(fullRed: red, fullGreen: green, fullBlue: blue)
    }
    
    public convenience init(hexString: String) {
        var hexInt: UInt32 = 0
        let success = Scanner(string: hexString).scanHexInt32(&hexInt)
        if (success) {
            self.init(hex: hexInt)
        } else {
            self.init(white: 0.8, alpha: 1.0)
        }
    }
    
}

extension UIColor {
    
    ///
    /// Brighten a color without changing its hue.
    /// - Parameters:
    ///     - delta: The delta by which to brighten the color. Defaults to 0.18
    ///
    public func brightened(by delta: CGFloat = 0.18) -> UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        r = min(1.0, r + delta)
        g = min(1.0, g + delta)
        b = min(1.0, b + delta)
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    ///
    /// Darken a color without changing its hue.
    /// - Parameters:
    ///     - delta: The delta by which to darken the color. Defaults to 0.18
    ///
    public func darkened(by delta: CGFloat = 0.18) -> UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        r = max(0.0, r - delta)
        g = max(0.0, g - delta)
        b = max(0.0, b - delta)
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    ///
    /// Whether or not the color is very light, e.g. close to white
    /// - Note: Useful for determining whether or not a light or dark interface style should be used with the receiver.
    ///
    public var isVeryLight: Bool {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        
        let rgbMin: CGFloat = 0.88, brightnessMin: CGFloat = 0.9, satMax: CGFloat = 0.1
        return (r > rgbMin && g > rgbMin && b > rgbMin) && (brightness > brightnessMin && saturation < satMax)
    }
    
}

extension UIColor {
    
    ///
    /// Prints the red, green, blue, and alpha components
    /// as well as the hue, saturation, and brightness components
    ///
    public var componentsDescription: String {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        
        return """
        Red: \(r), Green: \(g), Blue: \(b), Alpha: \(alpha)
        Hue: \(hue), Saturation: \(saturation), Brightness: \(brightness)
        """
    }
    
}
