//
//  ModernSliderControl.swift
//  PDFToKeynote
//
//  Created by Blue on 4/14/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class ModernSliderControl: UIControl {
    var iconView: UIImageView!
    var percentageLabel: UILabel!
    var progressColorView: UIView!
    var containerView: UIVisualEffectView!
    var popoverView: UIView!
    var panRecongnizer: UIPanGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }

    override func awakeFromNib() {
        configurate()
    }

    func configurate() {
        self.layer.cornerRadius = 23.0
        self.containerView = UIVisualEffectView(frame: frame)
        self.addSubview(containerView)
        self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.containerView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
