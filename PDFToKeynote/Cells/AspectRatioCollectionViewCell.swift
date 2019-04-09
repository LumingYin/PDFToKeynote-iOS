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
    var ratioCorrespondingIndex: Int = 0
    var correspondingSize: SlideSize!

    func configurateCellAppearance() {
        self.greenTickView.isHidden = true
        self.nativeGoldstarView.isHidden = true
    }

    @IBAction func selectSizeTapped(_ sender: Any) {
        self.greenTickView.isHidden = false
        delegate.selectSizeAtIndex(index: ratioCorrespondingIndex)
    }

}
