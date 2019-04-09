//
//  UIStoryboard+Core.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 1/6/19.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    ///
    /// The main storyboard in the apaplication bundle
    ///
    public class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

}
