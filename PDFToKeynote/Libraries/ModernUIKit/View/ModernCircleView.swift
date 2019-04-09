//
//  ModernCircleView.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 10/7/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

@IBDesignable
open class ModernCircleView: UIView {

    // MARK: - UIView subclass
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.layer.masksToBounds = true
    }

}
