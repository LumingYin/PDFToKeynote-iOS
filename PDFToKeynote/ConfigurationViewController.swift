//
//  ConfigurationViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/8/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController {
    @IBOutlet weak var customizeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "Settings")!.withRenderingMode(.alwaysTemplate)
        customizeImageView.image = image
        customizeImageView.tintColor = UIColor(named: "customBlue")
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
