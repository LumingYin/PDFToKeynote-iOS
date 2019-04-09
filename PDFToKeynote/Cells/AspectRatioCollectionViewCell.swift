//
//  AspectRatioCollectionViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class AspectRatioCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ratioTextLabel: UILabel!
    @IBOutlet weak var nativeGoldstarView: UIImageView!
    @IBOutlet weak var visualEffectContainerView: UIVisualEffectView!
    @IBOutlet weak var greenTickView: UIImageView!
    weak var delegate: SlideSizeDelegate!
    weak var parentTableCell: SlideSizeTableViewCell!
    var ratioCorrespondingIndex: Int = 0
    var correspondingSize: SlideSize!

    func configurateCellAppearance() {
        print("AspectRatioCollectionViewCell.bounds: \(self.bounds)")
        self.greenTickView.isHidden = ratioCorrespondingIndex != delegate.getSelectedSizeIndex()
        self.nativeGoldstarView.isHidden = ratioCorrespondingIndex != delegate.getNativeSizeIndex()
        let maxSide = self.bounds.width

        // screen ratios always have a width of 80
//        if ratioCorrespondingIndex < self.delegate.getCutoffCountForScreenResolution() {
        var paintWidth: CGFloat = maxSide
        var ratio = paintWidth / CGFloat(correspondingSize.width)
        var paintHeight: CGFloat = ratio * CGFloat(correspondingSize.height)
        if (paintHeight > maxSide) {
            paintHeight = maxSide
            ratio = paintHeight / CGFloat(correspondingSize.height)
            paintWidth = ratio * CGFloat(correspondingSize.width)
        }
        visualEffectContainerView.frame = CGRect(x: (self.bounds.width - paintWidth) / 2, y: (self.bounds.height - paintHeight) / 2, width: paintWidth, height: paintHeight)
        ratioTextLabel.center = CGPoint(x: visualEffectContainerView.frame.width / 2, y: visualEffectContainerView.frame.height / 2)
//        ratioTextLabel.sizeToFit()
//        }

        if self.ratioCorrespondingIndex == self.delegate.getNativeSizeIndex() {
            self.nativeGoldstarView.frame = CGRect(x: visualEffectContainerView.frame.origin.x + visualEffectContainerView.frame.size.width - 20, y: visualEffectContainerView.frame.origin.y + 10, width: self.nativeGoldstarView.frame.size.width, height: self.nativeGoldstarView.frame.size.height)
//            self.nativeGoldstarView.center = CGPoint(x: visualEffectContainerView.frame.origin.x + visualEffectContainerView.frame.size.width - 20, y: visualEffectContainerView.frame.origin.y + 10)
//            self.nativeGoldstarView.frame = CGRect(x: ratioTextLabel.frame.origin.x - self.nativeGoldstarView.frame.width, y: ratioTextLabel.frame.origin.y, width: self.nativeGoldstarView.frame.width, height: self.nativeGoldstarView.frame.height)
//            self.ratioTextLabel.frame = CGRect(x: self.ratioTextLabel.frame.origin.x + self.nativeGoldstarView.frame.width, y: self.ratioTextLabel.frame.origin.y, width: self.ratioTextLabel.frame.width, height: self.ratioTextLabel.frame.height)
            self.nativeGoldstarView.isHidden = false
        }
    }

    @IBAction func selectSizeTapped(_ sender: Any) {
        self.greenTickView.isHidden = false
        delegate.selectSizeAtIndex(index: ratioCorrespondingIndex)
//        var paths : [IndexPath] = []
        for i in 0..<delegate.getAllSizes().count {
            if i != ratioCorrespondingIndex {
                let correctedI = i >= delegate.getCutoffCountForScreenResolution() ? i - delegate.getCutoffCountForScreenResolution() : i
                let section = i >= delegate.getCutoffCountForScreenResolution() ? 1 : 0
                let path = IndexPath(row: correctedI, section: section)
                if let toDehighlight = self.parentTableCell.collectionView.cellForItem(at: path) as? AspectRatioCollectionViewCell {
                    toDehighlight.greenTickView.isHidden = true
                }
//                paths.append()
            }
        }
//        self.parentTableCell.collectionView.reloadItems(at: paths)
    }

}
