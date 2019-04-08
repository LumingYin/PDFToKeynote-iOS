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
        if let callback = self.newSizeAdded, let width = Int(widthTextField.text ?? ""), let height = Int(heightTextField.text ?? "") {
            callback(width, height)
            self.dismiss(animated: true, completion: nil)
        }
    }

}
