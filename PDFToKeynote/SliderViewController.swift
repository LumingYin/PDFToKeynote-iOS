//
//  SliderViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/14/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class SliderViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var scalerView: UIImageView!
    @IBOutlet weak var scaleTypeLabel: UILabel!
    @IBOutlet weak var scalePercentLabel: UILabel!
    @IBOutlet weak var blueBarView: UIView!
    @IBOutlet weak var containerVisualEffectView: UIVisualEffectView!
    @IBOutlet var gestureRecongnizer: UIPanGestureRecognizer!
    @IBOutlet weak var barConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.cornerRadius = 23.0
        gestureRecongnizer.delegate = self
        let image = UIImage(named: "scaler")!.withRenderingMode(.alwaysTemplate)
        scalerView.image = image
    }

    private var sliderValue: Float = 1
    var percentageValue: Float {
        set {
            let bounds = self.view.bounds.size
            var toUse = newValue

            self.barConstraint.constant = bounds.width * CGFloat((1 - toUse))
            self.scalePercentLabel.text = String(format: "%.0f%%", newValue * 100)
        }
        get {
            let value = self.view.frame.width - (self.barConstraint.constant / self.view.frame.width)
            if value < 0.1 { return 0.1 }
            if value > 0.95 { return 1 }
            return Float(value)
        }
    }

    @IBAction func gesturePanned(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        print("\(sender.state): \(translation)")
        let new = self.containerVisualEffectView.frame.width - (barConstraint.constant - translation.x)
        let percentage = Float(new / self.containerVisualEffectView.frame.width)
        var toUse = percentage
        if (sender.state == .ended || sender.state == .cancelled || sender.state == .failed) {
            if toUse < 0.05 { toUse = 0.05 }
            if toUse > 1 { toUse = 1 }
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                self.percentageValue = toUse
                self.view.layoutIfNeeded()
            }
        } else {
            if toUse < 0 { toUse = 0 }
            if toUse > 1 { toUse = 1 }
            percentageValue = toUse
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
