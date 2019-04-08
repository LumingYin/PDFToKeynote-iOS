//
//  Extensions.swift
//  PDFToKeynote
//
//  Created by Blue on 4/7/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import Foundation

extension String {
    func stripFileExtension () -> String {
        var components = self.components(separatedBy: ".")
        guard components.count > 1 else { return self }
        components.removeLast()
        return components.joined(separator: ".")
    }

}
