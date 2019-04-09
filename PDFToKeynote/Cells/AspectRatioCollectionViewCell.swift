//
//  AspectRatioCollectionViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class AspectRatioCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var effectsHeight: NSLayoutConstraint!
    @IBOutlet weak var effectsWidth: NSLayoutConstraint!
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

        var paintWidth: CGFloat = maxSide
        var ratio = paintWidth / CGFloat(correspondingSize.width)
        var paintHeight: CGFloat = ratio * CGFloat(correspondingSize.height)
        if (paintHeight > maxSide) {
            paintHeight = maxSide
            ratio = paintHeight / CGFloat(correspondingSize.height)
            paintWidth = ratio * CGFloat(correspondingSize.width)
        }
        effectsWidth.constant = paintWidth
        effectsHeight.constant = paintHeight

        if self.ratioCorrespondingIndex == self.delegate.getNativeSizeIndex() {
            self.nativeGoldstarView.isHidden = false
        }
    }

    func configurateAsNativeSize() {
        self.nativeGoldstarView.isHidden = false
        for i in 0..<delegate.getAllSizes().count {
            if i != ratioCorrespondingIndex {
                let path = ConfigurationViewController.findIndexPathForResolutionIndex(i: i, delegate: delegate)
                if let toDehighlight = self.parentTableCell.collectionView.cellForItem(at: path) as? AspectRatioCollectionViewCell {
                    toDehighlight.nativeGoldstarView.isHidden = true
                }
            }
        }
    }

    @IBAction func selectSizeTapped(_ sender: Any) {
        self.greenTickView.isHidden = false
        delegate.selectSizeAtIndex(index: ratioCorrespondingIndex)
        for i in 0..<delegate.getAllSizes().count {
            if i != ratioCorrespondingIndex {
                let path = ConfigurationViewController.findIndexPathForResolutionIndex(i: i, delegate: delegate)
                if let toDehighlight = self.parentTableCell.collectionView.cellForItem(at: path) as? AspectRatioCollectionViewCell {
                    toDehighlight.greenTickView.isHidden = true
                }
            }
        }
    }

}
