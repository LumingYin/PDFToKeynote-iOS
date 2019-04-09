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
    var correspondingIndex: Int = 0
    var colorTappedCallback: ((_ color: UIColor, _ index: (Int, Int), _ cell: MultipleColorCollectionViewCell) -> ())?

    @IBAction func colorButtonTapped(_ sender: UIButton) {
//        delegate?.changeToNewColor(color: sender.backgroundColor!)
        var index = 0
        if sender == color1Button {
            index = 0
        } else if sender == color2Button {
            index = 1
        } else if sender == color3Button {
            index = 2
        } else if sender == color4Button {
            index = 3
        }
        colorTappedCallback?(sender.backgroundColor!, (correspondingIndex, index), self)
    }

    func setTickAtLocation(_ location: Int) {
        greenTickView.frame = CGRect(x: (self.bounds.width - greenTickView.frame.width) / 2, y: (self.bounds.height / 4) * CGFloat(location), width: greenTickView.frame.width, height: greenTickView.frame.height)
    }
}
