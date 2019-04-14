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



        // Do any additional setup after loading the view.
    }

    private var sliderValue: Float = 1
    var percentageValue: Float {
        set {
            let bounds = self.view.bounds.size
            var toUse = newValue
            if toUse < 0.1 { toUse = 0.1 }
            if toUse > 0.95 { toUse = 1 }

            self.barConstraint.constant = bounds.width * CGFloat((1 - newValue))
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
        print("\(translation)")
        var new = self.containerVisualEffectView.frame.width - (barConstraint.constant - translation.x)
//        if new >= containerVisualEffectView.frame.width * 0.95 {
//            new = containerVisualEffectView.frame.width
//        }
//        if new < 0.1 {
//            new = 0
//        }
//        barConstraint.constant = barConstraint.constant + (translation.x / self.containerVisualEffectView.frame.width)
        percentageValue = Float(new / self.containerVisualEffectView.frame.width)
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
