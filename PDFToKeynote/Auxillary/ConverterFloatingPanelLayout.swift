//
//  ConverterFloatingPanelLayout.swift
//  PDFToKeynote
//
//  Created by Blue on 4/8/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import FloatingPanel

class ConverterFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        let window = UIApplication.shared.keyWindow
//        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return (285.0 - bottomPadding) // A bottom inset from the safe area
        case .tip: return (150.0 - bottomPadding) // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }

    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
        ]
    }
}

let iPadPixelOffset: CGFloat = 3

public class ConverterFloatingLandscapePanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half, .tip]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        let window = UIApplication.shared.keyWindow
        //        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return (285.0 - iPadPixelOffset - bottomPadding) // A bottom inset from the safe area
        case .tip: return (150.0 - iPadPixelOffset - bottomPadding) // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }

    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -18.0),
            surfaceView.widthAnchor.constraint(equalToConstant: 320),
        ]
    }

    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}

public class ConverterFloatingiPadNonLandscapePanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half, .tip]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        let window = UIApplication.shared.keyWindow
        //        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return (285.0 - iPadPixelOffset - bottomPadding) // A bottom inset from the safe area
        case .tip: return (150.0 - iPadPixelOffset - bottomPadding) // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }

    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
            surfaceView.widthAnchor.constraint(equalToConstant: 320),
        ]
    }

    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}
