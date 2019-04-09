//
//  ModernGridView.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/27/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A view that arranges subviews into a (row x column) grid
///
open class ModernGridView: ModernGradientView {
    
    // MARK: - Public
    
    open var rows: Int = 0
    open var columns: Int = 0
    
    public var spacing: CGFloat = 0.0
    public var separatorStyle: SeparatorStyle = .none {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public enum SeparatorStyle {
        case none
        case singleLine
    }
    
    public func reloadArrangedViews() {
        self.needsArrangedViewReload = true
        reloadArrangedViewsIfNeeded()
    }
    
    ///
    /// Access the arranged views in the grid
    ///
    open subscript(indexPath: IndexPath) -> UIView? {
        self.reloadArrangedViewsIfNeeded()
        return self.arrangedViews[indexPath.linearGridIndex(forColumns: columns)]
    }
    open subscript(index: Int) -> UIView? {
        self.reloadArrangedViewsIfNeeded()
        return self.arrangedViews[index]
    }
    
    
    ///
    /// Enumerate the arranged views to perform an operation
    ///
    open func enumerateViews(using block: (_ view: UIView?, _ indexPath: IndexPath, _ stop: inout Bool) -> Void) {
        self.reloadArrangedViewsIfNeeded()
        var stop = false
        
        out: for row in 0..<rows {
            for col in 0..<columns {
                let indexPath = IndexPath(row: row, column: col)
                let arrangedView = self[indexPath]
                
                block(arrangedView, indexPath, &stop)
                if stop {
                    break out
                }
            }
        }
    }
    
    
    // MARK: - For subclasses
    
    ///
    /// Subclasses must override this method to provide the view to be used at each indexPath
    /// - Parameters:
    ///    - indexPath: the indexPath at which the requested view will be positioned. Use the row and column properties.
    /// */
    open func arrangedView(at indexPath: IndexPath) -> UIView? {
        return nil
    }
    
    
    // MARK: - Lifecycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(separatorLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.addSublayer(separatorLayer)
    }
    
    
    // MARK: - UIView subclass
    
    override open func layoutSubviews() {
    
        // Reload arranged subviews if needed
        reloadArrangedViewsIfNeeded()
        arrangeSeparatorsIfNeeded()
        
        // Layout arranged subviews
        let insetFrame = self.bounds.inset(by: self.layoutMargins)
        let elementHeight = insetFrame.size.height / CGFloat(rows)
        let elementWidth = insetFrame.size.width / CGFloat(columns)
        
        for row in 0..<rows {
            for column in 0..<columns {
                let indexPath = IndexPath(row: row, column: column)
                let index = indexPath.linearGridIndex(forColumns: columns)

                if let arrangedView = self.arrangedViews[index] {
                    
                    var frame = insetFrame
                    frame.origin.x += (elementWidth * CGFloat(column))
                    frame.origin.y += (elementHeight * CGFloat(row))
                    frame.size.width = elementWidth
                    frame.size.height = elementHeight
                    
                    // NOTE: this is where the margin-looking layout is created
                    let inset = spacing / 2.0
                    let spacedInsetFrame = frame.inset(by: UIEdgeInsets(constant: inset))
                    
                    arrangedView.frame = spacedInsetFrame.rounded()
                }
            }
        }
        
        setCornerMasksIfNecessary()
    }
    
    
    // MARK: - Private
    
    private var arrangedViews: [UIView?] = []
    private let separatorLayer = CAShapeLayer()
    
    fileprivate var needsArrangedViewReload: Bool = true {
        didSet {
            if (needsArrangedViewReload) {
                self.setNeedsLayout()
            }
        }
    }
    
    private func reloadArrangedViewsIfNeeded() {
        if needsArrangedViewReload {
            for arrangedView in arrangedViews {
                arrangedView?.removeFromSuperview()
            }
            arrangedViews.removeAll()
            arrangedViews = Array(repeating: nil, count: rows * columns)
            
            for row in 0..<rows {
                for column in 0..<columns {
                    let indexPath = IndexPath(row: row, column: column)
                    if let arrangedView = self.arrangedView(at: indexPath) {
                        let index = indexPath.linearGridIndex(forColumns: columns)
                        self.arrangedViews[index] = arrangedView
                        self.addSubview(arrangedView)
                    }
                }
            }
            // We no longer need to reload our arranged views
            needsArrangedViewReload = false
            
            self.setCornerMasksIfNecessary()
        }
    }
    
    private func arrangeSeparatorsIfNeeded() {
        
        guard rows > 0, columns > 0 else { return }
        
        if separatorStyle == .singleLine {

            let layoutMargins = self.layoutMargins
            let insetFrame = self.bounds.inset(by: layoutMargins)
            let elementHeight = insetFrame.size.height / CGFloat(rows)
            let elementWidth = insetFrame.size.width / CGFloat(columns)
            let strokeColor = UIColor.lightGray.withAlphaComponent(0.8)

            let path = UIBezierPath()

            for row in 1..<rows {
                let x = layoutMargins.left + (CGFloat(row) * elementWidth)
                path.move(to: CGPoint(x: x, y: insetFrame.minY))
                path.addLine(to: CGPoint(x: x, y: insetFrame.maxY))
            }
            
            for col in 1..<columns {
                let y = layoutMargins.top + (CGFloat(col) * elementHeight)
                path.move(to: CGPoint(x: insetFrame.minX, y: y))
                path.addLine(to: CGPoint(x: insetFrame.maxX, y: y))
            }
            
            separatorLayer.path = path.cgPath
            separatorLayer.strokeColor = strokeColor.cgColor
            separatorLayer.fillColor = UIColor.clear.cgColor
            separatorLayer.lineWidth = 0.8

        } else {
            
            separatorLayer.path = nil
            
        }
        
    }
    
    private func setCornerMasksIfNecessary() {
        self.reloadArrangedViewsIfNeeded()
        
        guard rows > 0, columns > 0 else { return }
        
        if let topLeft = self[0] {
            topLeft.layer.maskedCorners = .layerMinXMinYCorner
            topLeft.cornerRadius = self.layer.cornerRadius
        }
        
        if let topRight = self[columns - 1] {
            topRight.layer.maskedCorners = .layerMaxXMinYCorner
            topRight.cornerRadius = self.layer.cornerRadius
        }
        
        if let bottomLeft = self[(rows * columns) - columns] {
            bottomLeft.layer.maskedCorners = .layerMinXMaxYCorner
            bottomLeft.cornerRadius = self.layer.cornerRadius
        }
        
        if let bottomRight = self[(rows * columns) - 1] {
            bottomRight.layer.maskedCorners = .layerMaxXMaxYCorner
            bottomRight.cornerRadius = self.layer.cornerRadius
        }

    }

}
