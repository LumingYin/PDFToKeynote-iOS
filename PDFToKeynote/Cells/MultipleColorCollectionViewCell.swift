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
    var colorTappedCallback: ((_ color: UIColor, _ index: (Int, Int), _ cell: MultipleColorCollectionViewCell) -> ())?

    @IBAction func colorButtonTapped(_ sender: UIButton) {
//        delegate?.changeToNewColor(color: sender.backgroundColor!)
        colorTappedCallback?(sender.backgroundColor!, correspondingIndex ?? (0, 0), self)
    }

    func setTickAtLocation(_ location: Int) {
        greenTickView.frame = CGRect(x: (self.bounds.height / 4) * CGFloat(location), y: (self.bounds.width - greenTickView.frame.width) / 2, width: greenTickView.frame.width, height: greenTickView.frame.height)
    }
}
