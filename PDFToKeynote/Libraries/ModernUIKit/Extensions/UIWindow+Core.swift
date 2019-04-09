//
//  UIWindow+Core.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 11/24/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIWindow {
    
    public func topPresentedViewController() -> UIViewController {
        return self.rootViewController!.topmostPresentedViewController
    }
    
}
