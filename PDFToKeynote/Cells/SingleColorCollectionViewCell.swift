//
//  SingleColorCollectionViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class SingleColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var greenTickView: UIImageView!
    weak var delegate: ColorPickerDelegate?
    var correspondingIndex: Int?
    var colorTappedCallback: ((_ color: UIColor, _ index: Int, _ cell: SingleColorCollectionViewCell) -> ())?
    @IBOutlet weak var selectColorButton: ModernFluidButton!

    override func awakeFromNib() {
        selectColorButton.trackedViews = [colorView, greenTickView]
    }

    @IBAction func colorButtonTapped(_ sender: UIButton) {
        colorTappedCallback?(colorView.backgroundColor!, correspondingIndex ?? 0, self)
    }
}
