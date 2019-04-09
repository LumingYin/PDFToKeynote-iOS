//
//  MultipleColorCollectionViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class MultipleColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var colorContainerView: UIView!
    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var color3Button: UIButton!
    @IBOutlet weak var color4Button: UIButton!
    @IBOutlet weak var greenTickView: UIImageView!
    weak var delegate: ColorPickerDelegate?
    var correspondingIndex: (Int, Int)?
    var colorTappedCallback: ((_ index: (Int, Int), _ cell: MultipleColorCollectionViewCell) -> ())?

    @IBAction func colorButtonTapped(_ sender: UIButton) {
        delegate?.changeToNewColor(color: sender.backgroundColor!)
    }
}
