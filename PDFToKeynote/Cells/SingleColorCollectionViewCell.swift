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

    @IBAction func colorButtonTapped(_ sender: UIButton) {
        delegate?.changeToNewColor(color: sender.backgroundColor!)
    }
}
