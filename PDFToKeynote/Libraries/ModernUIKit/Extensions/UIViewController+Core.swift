//
//  UIViewController+Core.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/23/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIViewController {
    
    ///
    /// Instantiate this view controller from the specified Storyboard
    /// - Requires: That the view controller have the storyboard identifier set to its class name
    /// - Parameters:
    ///     - storyboard: The UIStoryboard to which the view controller belongs
    ///
    @objc open class func instantiate(from storyboard: UIStoryboard = UIStoryboard.main) -> UIViewController {
        let identifier = self.classForCoder().description()
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    ///
    /// Determine if a view controller is or is presenting a certain type of view controller
    ///
    open func isOrPresenting(_ viewControllerType: AnyClass) -> Bool {
        if self.classForCoder == viewControllerType {
            return true
        }
        if let navigationVC = self as? UINavigationController {
            for childVC in navigationVC.viewControllers {
                if childVC.isOrPresenting(viewControllerType) {
                    return true
                }
            }
        }
        if let tabBarVC = self as? UITabBarController {
            for childVC in tabBarVC.viewControllers ?? [] {
                if childVC.isOrPresenting(viewControllerType) {
                    return true
                }
            }
        }
        
        for childVC in self.children {
            if childVC.isOrPresenting(viewControllerType) {
                return true
            }
        }
        
        return false
    }
    
    ///
    /// The topmost presented view controller on top of the receiver or the receiver
    ///
    public var topmostPresentedViewController: UIViewController {
        return self.topmostPresentedViewController(on: self)
    }
    
    private func topmostPresentedViewController(on viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return self.topmostPresentedViewController(on: presented)
        }
        return viewController
    }
    
    ///
    /// Dismiss all presented child and contained view controllers
    ///
    public func dismissAllPresented(animated: Bool, completion: (() -> Void)? = nil) {
        
        let dismissSelfBlock = {
            self.dismiss(animated: animated, completion: completion)
        }
        
        if let presented = self.presentedViewController {
            presented.dismissAllPresented(animated: animated, completion: {
                dismissSelfBlock()
            })
        } else {
            dismissSelfBlock()
        }
    }
    
    ///
    /// Finds the parent View Controller that defines the presentation context
    ///
    open var presentationContextDefiningViewController: UIViewController {
        var contextDefiningViewController = self
        
        while !contextDefiningViewController.definesPresentationContext,
            let nextParent = contextDefiningViewController.presentingViewController {
            contextDefiningViewController = nextParent
        }
        
        return contextDefiningViewController
    }
    
    ///
    /// Convenience action to connect from Storyboards
    ///
    @IBAction public func dismiss(for sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
