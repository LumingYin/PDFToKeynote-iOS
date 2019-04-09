//
//  ConverterFloatingPanelLayout.swift
//  PDFToKeynote
//
//  Created by Blue on 4/8/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import FloatingPanel

class ConverterFloatingPanelLayout: FloatingPanelDefaultLayout {
    override public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    override func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 300.0 // A bottom inset from the safe area
        case .tip: return 150.0 // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}

class ConverterFloatingLandscapePanelLayout: ConverterFloatingPanelLayout {
    override public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }

//    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
//        switch position {
//        case .full: return 16.0
//        case .tip: return 69.0
//        default: return nil
//        }
//    }

    override func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
            surfaceView.widthAnchor.constraint(equalToConstant: 291),
        ]
    }

}
