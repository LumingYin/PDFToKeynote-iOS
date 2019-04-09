//
//  ModernCollectionViewFlowLayout.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 9/3/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A flexible and adaptive UICollectionViewFlowLayout
///
open class ModernCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - Public
    
    ///
    /// The width:height aspect ratio of the cell given that it will fill its smallest bound constraint.
    /// Defaults to 1:1, representing a square ratio.
    ///
    public var cellAspectRatio: CGSize = CGSize(width: 1.0, height: 1.0)
    
    ///
    /// The manual constant to add to the width and height of the cell after aspect ratio calculation.
    /// Defaults to 0 and 0, leaving the square ratio.
    ///
    public var cellDimensionConstantOffset: CGSize = CGSize(width: 0.0, height: 0.0)
    
    ///
    /// Whether or not the collectionView should continue scrolling after deceleration begins such that
    /// the scrolling will end with the leading cell displayed fully and positioned against the leading edge.
    ///
    public var shouldSnapToIntegralCellPosition: Bool = true
    
    
    // MARK: - UICollectionViewFlowLayout
    
    override open func prepare() {
        
        guard let collectionView = self.collectionView else { return }
        collectionView.insetsLayoutMarginsFromSafeArea = true

        self.sectionInset = .zero
        self.sectionInsetReference = .fromSafeArea
        
        if scrollDirection == .horizontal {
            let availableHeight = collectionView.bounds.inset(by: collectionView.layoutMargins).inset(by: collectionView.contentInset).size.height - sectionInset.top - sectionInset.bottom
            
            let widthAspectRatio = self.cellAspectRatio.width / self.cellAspectRatio.height
            let cellWidth = (availableHeight * widthAspectRatio) + self.cellDimensionConstantOffset.width
            self.itemSize = CGSize(width: cellWidth, height: availableHeight)
        } else {
            let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).inset(by: collectionView.contentInset).size.width - sectionInset.left - sectionInset.right
            
            let widthAspectRatio = self.cellAspectRatio.width / self.cellAspectRatio.height
            let cellHeight = (availableWidth / widthAspectRatio) + self.cellDimensionConstantOffset.height
            self.itemSize = CGSize(width: availableWidth, height: cellHeight)
        }
        
        // ALWAYS CALL SUPER **AFTER** SETTING THE ITEM SIZE
        super.prepare()
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        // DO NOT invalidate our layout during simple scrolling
        guard let oldSize = self.collectionView?.bounds.size else { return true }
        return oldSize != newBounds.size
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard self.shouldSnapToIntegralCellPosition, let collectionView = self.collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left + collectionView.safeAreaInsets.left

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)

        if let layoutAttributes = super.layoutAttributesForElements(in: targetRect) {
            for layoutAttribute in layoutAttributes {
                let itemOffset = layoutAttribute.frame.origin.x
                if abs(CGFloat(itemOffset - horizontalOffset)) < abs(CGFloat(offsetAdjustment)) {
                    offsetAdjustment = itemOffset - horizontalOffset
                }
            }
            
            // Somewhat special case for when we scroll to the end of the collection view
            // Because of how the math works out with a nonzero TRAILING safeAreaInset, we need to explicitly give
            // the last collectionView cell another chance to be our preferred auto-scrolled-to cell.
            if let last = layoutAttributes.last {
                if last.indexPath.row == collectionView.numberOfItems(inSection: last.indexPath.section) - 1
                    && velocity.x > 0 {
                    offsetAdjustment = last.frame.origin.x - horizontalOffset
                }
            }
            
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

}
