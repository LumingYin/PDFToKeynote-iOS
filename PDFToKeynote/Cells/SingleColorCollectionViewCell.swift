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
    var colorTappedCallback: ((_ index: Int, _ cell: SingleColorCollectionViewCell) -> ())?

    @IBAction func colorButtonTapped(_ sender: UIButton) {
        delegate?.changeToNewColor(color: colorView.backgroundColor!)
        colorTappedCallback?(correspondingIndex ?? 0, self)
    }
}
