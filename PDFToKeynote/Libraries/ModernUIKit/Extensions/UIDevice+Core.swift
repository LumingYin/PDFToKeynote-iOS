//
//  UIDevice+Core.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/3/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit


// MARK: - Shortcut Capability

extension UIDevice {
    
    ///
    /// Currently, only iPhones support quick actions.
    /// iPads, Apple TVs, and Apple Watches do not.
    ///
    public var hasShortcutCapability: Bool {
        return self.userInterfaceIdiom == .phone
    }
    
}


// MARK: - Target OS

extension UIDevice {
    
    ///
    /// Whether or not the targeted OS is the iOS Simulator
    /// Equivalent to the TARGET_IPHONE_SIMULATOR check in Objective-C
    /// - Note: https://github.com/apple/swift-evolution/blob/master/proposals/0190-target-environment-platform-condition.md
    ///
    public var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

}


// MARK: - App Icon

extension UIDevice {
    
    ///
    /// The possible size classes of the app icons displayed on the iOS Home Screen
    /// The actual icon point size for each size class is its raw value
    ///
    public enum AppIconSize: Double {
        case phone      = 60.0
        case pad        = 76.0
        case padLarge   = 83.5
        
        public var asString: String {
            return String(format: "%g", self.rawValue)  // 60.0 -> "60"
        }
    }
    
    ///
    /// The size in points of the app icons displayed on the Home Screen for the given device
    ///
    public var appIconSize: AppIconSize {
        if self.userInterfaceIdiom == .phone {
            return .phone
        } else if (UIScreen.main.bounds.size.isCongruent(to: CGSize(width: 1024, height: 1366))) {
            return .padLarge
        }
        return .pad
    }
    
    
    ///
    /// The types of iOS device products
    ///
    public enum ProductType {
        case unknown
        case iPhoneSmall
        case iPhoneN
        case iPhoneNPlus
        case iPhoneX
        case iPhoneXSMax
        case iPad
    }
    
    ///
    /// The product type of the device
    ///
    public var productType: ProductType {
        if self.userInterfaceIdiom == .pad {
            return .iPad
        } else if self.userInterfaceIdiom == .phone {
            let mainScreen = UIScreen.main
            let screenSize = mainScreen.bounds.size
            let screenScale = mainScreen.scale
            if screenSize.isCongruent(to: CGSize(width: 320, height: 568)) {
                return .iPhoneSmall
            } else if screenSize.isCongruent(to: CGSize(width: 375, height: 667)) {
                return screenScale == 3.0 ? .iPhoneNPlus : .iPhoneN
            } else if screenSize.isCongruent(to: CGSize(width: 414, height: 736)) {
                return .iPhoneNPlus
            } else if screenSize.isCongruent(to: CGSize(width: 375, height: 812)) {
                return .iPhoneX
            } else if screenSize.isCongruent(to: CGSize(width: 414, height: 896)) {
                return .iPhoneXSMax
            }
            return .unknown
        }
        return .unknown
    }
    
}
