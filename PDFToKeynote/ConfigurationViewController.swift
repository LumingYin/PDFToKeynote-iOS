//
//  ConfigurationViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/8/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import PDFKit

class ConfigurationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChromaColorPickerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var customizeImageView: UIImageView!
    @IBOutlet weak var startConversionButton: UIButton!
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var dimensionPicker: UIPickerView!
    @IBOutlet weak var aspectRatioLabel: UILabel!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var customizeAspectRatioButton: UIButton!
    var pdf: PDFDocument!
    weak var document: UIDocument?
    var enableDisableStateChanged: ((Bool) -> ())?

    var neatColorPicker: ChromaColorPicker!

    var selectedColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            colorPickerButton.backgroundColor = selectedColor
        }
    }
    var selectedRow: Int {
        get {
            return self.dimensionPicker.selectedRow(inComponent: 0)
        }
    }

    var sizes: [(width: Int, height: Int, description: String)] = [
        (1024, 768, "4:3 XGA"),
        (1920, 1080, "16:9 WUXGA/HDTV"),
        (1680, 1050, "16:10 WSXGA+"),
        (612, 792, "US Letter (Portrait)"),
        (792, 612, "US Letter (Landscape)"),
        (595, 842, "A4 Paper (Portrait)"),
        (842, 595, "A4 Paper (Landscape)"),
        (1600, 1200, "4:3 UXGA"),
        (800, 600, "4:3 SVGA"),
        (1280, 1024, "5:4 SXGA"),
        (1280, 720, "16:9 HDTV"),
        (1280, 800, "16:10 MacBook"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startConversionButton.setTitleColor(UIColor.darkGray, for: .disabled)
        let image = UIImage(named: "Settings")!.withRenderingMode(.alwaysTemplate)
        customizeImageView.image = image
        customizeImageView.tintColor = UIColor(named: "customBlue")
        dimensionPicker.dataSource = self
        dimensionPicker.delegate = self

    }

    func initialSetupForPDF(_ newDocument: Document) {
        self.document = newDocument
        self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
        guard let url = self.document?.fileURL else {fatalError("INVALID URL")}
        self.pdf = PDFDocument(url: url)
        let cgPDF = CGPDFDocument((url as CFURL))
        if let pdfPage = cgPDF!.page(at: 1) {
            let mediaBox = pdfPage.getBoxRect(.mediaBox)
            // print(mediaBox)
            let angle = CGFloat(pdfPage.rotationAngle) * CGFloat.pi / 180
            let rotatedBox = mediaBox.applying(CGAffineTransform(rotationAngle: angle))
            let ratio = Float(rotatedBox.width / rotatedBox.height)
            var matchedPreferredResolutions = false
            for i in 0..<self.sizes.count {
                let size = self.sizes[i]
                let sizeRatio = Float(size.width) / Float(size.height)
                if abs(ratio - sizeRatio) < 0.01 {
                    self.sizes[i].description = "\(self.sizes[i].description) (Native)"
                    self.dimensionPicker.selectRow(i, inComponent: 0, animated: true)
                    self.aspectRatioLabel.text = self.sizes[i].description
                    matchedPreferredResolutions = true
                    break
                }
            }
            if !matchedPreferredResolutions {
                let factor = max(1024 / rotatedBox.width, 768 / rotatedBox.height)
                //                        print("Scale factor is: \(factor)")
                let newWidth = rotatedBox.width * CGFloat(factor)
                let newHeight = rotatedBox.height * CGFloat(factor)
                self.sizes.append((Int(newWidth), Int(newHeight), "Native Resolution"))
                self.dimensionPicker.reloadComponent(0)
                self.dimensionPicker.selectRow(self.sizes.count - 1, inComponent: 0, animated: true)
                self.aspectRatioLabel.text = self.sizes.last?.description
            }
        }

    }

    @IBAction func buttonTouched(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
        }, completion: { finish in
            UIButton.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
            })
        })
    }

    @IBAction func startConversion(_ sender: Any) {
        SVProgressHUD.show()
        let cachedRow = self.selectedRow
        setConversionActivationState(active: false)
        DispatchQueue.global(qos: .userInitiated).async {
            self.performConversion(selectedRow: cachedRow)
        }
    }

    func performConversion(selectedRow: Int) {
        Converter.performConversion(pdf: pdf, selectedSize: sizes[selectedRow], selectedColor: selectedColor, pdfFileName: self.document?.fileURL.lastPathComponent.stripFileExtension(), conversionSucceededCallback: { (destinationUrl) -> (Void) in
            var filesToShare = [Any]()
            filesToShare.append(destinationUrl)
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.startConversionButton
            self.setConversionActivationState(active: true)
            self.present(activityViewController, animated: true, completion: nil)
        }) { () -> (Void) in
            self.setConversionActivationState(active: true)
        }
    }

    func setConversionActivationState(active: Bool) {
        DispatchQueue.main.async {
            if (active) {
                SVProgressHUD.dismiss()
                self.enableDisableStateChanged?(true)
                self.colorPickerButton.isEnabled = true
                self.dimensionPicker.isUserInteractionEnabled = true
                self.startConversionButton.isEnabled = true
                self.customizeAspectRatioButton.isEnabled = true
                self.startConversionButton.backgroundColor = UIColor(red: 0.3882352941, green: 0.7058823529, blue: 0.8431372549, alpha: 1)
            } else {
                self.enableDisableStateChanged?(false)
                self.colorPickerButton.isEnabled = false
                self.dimensionPicker.isUserInteractionEnabled = false
                self.startConversionButton.isEnabled = false
                self.startConversionButton.backgroundColor = UIColor.gray
                self.customizeAspectRatioButton.isEnabled = false
            }
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizes.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let (width, height, _) = sizes[row]
        // return "\(width) × \(height) - \(description)"
        let string = "\(width) × \(height)"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        aspectRatioLabel.text = sizes[selectedRow].description
    }

    @IBAction func changeColorTapped(_ sender: UIButton) {
        neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        neatColorPicker.supportsShadesOfGray = true
        neatColorPicker.togglePickerColorMode()
        neatColorPicker.adjustToColor(selectedColor)
        neatColorPicker.delegate = self
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
        let controller = PopoverViewController()
        controller.view = neatColorPicker
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 300, height: 300)
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.delegate = self
        presentationController.sourceView = sender
        presentationController.sourceRect = sender.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    @objc func colorChanged(_ colorPicker: ChromaColorPicker) {
        selectedColor = colorPicker.currentColor
    }

    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        selectedColor = color
    }

    @IBAction func addNewAspectRatioTapped(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "AddWidthHeight") as! AddWidthHeightViewController
        controller.newSizeAdded = { (width, height) in
            self.sizes.append((width, height, "Custom: \(width) × \(height)"))
            self.dimensionPicker.reloadComponent(0)
            self.dimensionPicker.selectRow(self.sizes.count - 1, inComponent: 0, animated: true)
            self.aspectRatioLabel.text = self.sizes[self.selectedRow].description
        }
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 300, height: 200)
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.backgroundColor = controller.view.backgroundColor
        presentationController.delegate = self
        presentationController.sourceView = sender
        presentationController.sourceRect = sender.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
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
