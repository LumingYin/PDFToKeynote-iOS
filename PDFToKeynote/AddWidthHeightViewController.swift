//
//  AddWidthHeightViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/8/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class AddWidthHeightViewController: UIViewController {
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    var newSizeAdded:((Int, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addTapped(_ sender: Any) {
        guard let callback = self.newSizeAdded else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        var width = 0
        var height = 0
        if let w = Int(widthTextField.text ?? "") {
            if (w > 300 && w < 8000) {
                width = w
            }
        }
        if let h = Int(heightTextField.text ?? "") {
            if (h > 300 && h < 8000) {
                height = h
            }
        }
        shake(shakeWidth: width == 0, shakeHeight: height == 0)
        if width != 0 && height != 0 {
            callback(width, height)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func shake(shakeWidth: Bool, shakeHeight: Bool) {
        if shakeWidth {
            widthTextField.shake()
        }
        if shakeHeight {
            heightTextField.shake()
        }
    }

}
