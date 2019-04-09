//
//  PlainNavigationBar.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/23/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A UINavigationBar that hides the bottom separator line and has a white background
///
class ModernNavigationBar: UINavigationBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.stylePlainly()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.stylePlainly()
    }

}

extension UINavigationBar {
    
    internal func stylePlainly() {
        self.barTintColor = UIColor.white
        self.backgroundColor = UIColor.white
        self.isTranslucent = true   // Setting this value to false changes the safeAreaInsets calculation -- don't do!
        self.shadowImage = UIImage()
    }

}
