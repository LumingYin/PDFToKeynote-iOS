//
//  IndexPath+Grid.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/28/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import Foundation

///
/// Use an IndexPath in the context of rows and columns in a grid
///
extension IndexPath {
    
    public static let zero: IndexPath = IndexPath(item: 0, section: 0)
    
    
    // MARK: - Lifecycle
    
    public init(row: Int, column: Int) {
        self.init(row: row, section: column)
    }
    
    public var column: Int {
        get {
            return self.section
        }
        set {
            self.section = newValue
        }
    }
    
    ///
    /// Use this IndexPath as a linear index into an array such that idx = (row * columns) + column
    /// - Parameters:
    ///     - columns: the number of columns in the grid
    ///
    public func linearGridIndex(forColumns columns: Int) -> Int {
        return (self.row * columns) + self.column
    }
    
}
