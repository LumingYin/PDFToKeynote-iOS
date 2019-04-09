//
//  UIViewController+Alerts.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 8/22/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Public
    
    public func presentAlert(_ title: String?, message: String?, completion: (() -> (Void))? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = okAction(withCompletion: completion, bolded: true)
        
        alert.addAction(ok)
        alert.preferredAction = ok
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func presentOpenSettingsAlert(_ title: String?, message: String?, completion: (() -> (Void))? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = okAction(withCompletion: completion, bolded: true)
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: { (success) in
                completion?()
            })
        }
        
        alert.addAction(ok)
        alert.addAction(settingsAction)
        alert.preferredAction = settingsAction
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func presentAlert(title: String?, message: String?, customActions actionsInAdditionToOKAction: [UIAlertAction], addOkAction: Bool = true) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for customAction in actionsInAdditionToOKAction {
            alert.addAction(customAction)
        }
        
        if addOkAction {
            let ok = okAction(withCompletion: nil, bolded: true)
            alert.addAction(ok)
            alert.preferredAction = ok
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Private
    
    private func okAction(withCompletion completion: (() -> (Void))?, bolded cancelStyleBolded: Bool) -> UIAlertAction {
        let style: UIAlertAction.Style = cancelStyleBolded ? .cancel : .default
        let action = UIAlertAction(title: "OK", style: style) { _ in
            completion?()
        }
        return action
    }
    
}
