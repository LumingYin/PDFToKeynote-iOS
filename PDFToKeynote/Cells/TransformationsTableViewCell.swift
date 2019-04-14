//
//  TransformationsTableViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/14/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class TransformationsTableViewCell: UITableViewCell {
    @IBOutlet weak var resetButton: ModernFluidButton!
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var scaleVisualContainer: UIVisualEffectView!
    @IBOutlet weak var rotationVisualContainer: UIVisualEffectView!
    @IBOutlet weak var scaleActivationView: UIView!
    @IBOutlet weak var rotationActivationView: UIView!
    @IBOutlet weak var scaleButton: ModernFluidButton!
    @IBOutlet weak var rotationButton: ModernFluidButton!
    @IBOutlet weak var longSliderView: UIView!
    @IBOutlet weak var longRotationView: UIView!
    var sliderController: SliderViewController!

    override func awakeFromNib() {
        super.awakeFromNib()
        resetButton.trackedViews = [resetLabel]
        rotationButton.trackedViews = [rotationVisualContainer]
        scaleButton.trackedViews = [scaleVisualContainer]

        longSliderView.layer.cornerRadius = 7.0
        longSliderView.clipsToBounds = true
        sliderController = UIStoryboard.main.instantiateViewController(withIdentifier: "SliderViewController") as? SliderViewController
        longSliderView.addSubview(sliderController.view)
        sliderController.view.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(longSliderView)
            make.top.bottom.equalTo(longSliderView)
        }
//        sliderController.view.leadingAnchor.constraint(equalTo: longSliderView.leadingAnchor).isActive = true
//        sliderController.view.trailingAnchor.constraint(equalTo: longSliderView.trailingAnchor).isActive = true
//        sliderController.view.topAnchor.constraint(equalTo: longSliderView.topAnchor).isActive = true
//        sliderController.view.bottomAnchor.constraint(equalTo: longSliderView.bottomAnchor).isActive = true

    }

    @IBAction func resetToNativeTransformationsTapped(_ sender: Any) {
    }

    @IBAction func specifyScaleTapped(_ sender: Any) {
    }

    @IBAction func specifyRotationTapped(_ sender: Any) {
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
