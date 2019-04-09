//
//  Array+ColorConversion.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 10/1/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit


// MARK: - [UIColor] to [CGColor]

extension Array where Element: UIColor {
    
    public var CGColors: [CGColor] {
        return self.map { (element) -> CGColor in
            element.cgColor
        }
    }

}


// MARK: - [CGColor] to [UIColor]

extension Array where Element: CGColor {
    
    public var UIColors: [UIColor] {
        return self.map { (element) -> UIColor in
            UIColor(cgColor: element)
        }
    }
    
}
