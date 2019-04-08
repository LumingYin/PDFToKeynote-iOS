//
//  DocumentViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/7/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import PDFKit
import Zip
import FloatingPanel

class DocumentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChromaColorPickerDelegate, UIPopoverPresentationControllerDelegate, FloatingPanelControllerDelegate {
    @IBOutlet weak var startConversionButton: UIButton!
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var dimensionPicker: UIPickerView!
    @IBOutlet weak var aspectRatioLabel: UILabel!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var natigationBarItem: UINavigationItem!
    @IBOutlet weak var navigationDoneButton: UIBarButtonItem!
    @IBOutlet weak var customizeAspectRatioButton: UIButton!

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
    var pdf: PDFDocument!
    var document: UIDocument?
    var fpc: FloatingPanelController?

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return ConverterFloatingPanelLayout()
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
//    var nativeSizesForPDF: [(width: Float, height: Float)] = []

    override func viewDidLoad() {
        self.startConversionButton.setTitleColor(UIColor.darkGray, for: .disabled)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if (traitCollection.horizontalSizeClass == .compact) {
            if fpc == nil {
                fpc = FloatingPanelController()
                fpc?.surfaceView.backgroundColor = .clear
                fpc?.surfaceView.cornerRadius = 9.0
                fpc?.surfaceView.shadowHidden = false
                // Assign self as the delegate of the controller.
                fpc?.delegate = self

                // Set a content view controller.
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let contentVC = storyBoard.instantiateViewController(withIdentifier: "ConfigurationViewController") as! ConfigurationViewController
                fpc?.set(contentViewController: contentVC)

                // Track a scroll view(or the siblings) in the content view controller.
                // fpc.track(scrollView: contentVC.tableView)
            }
            // Add and show the views managed by the `FloatingPanelController` object to self.view.
            fpc?.addPanel(toParent: self)
        } else {
            fpc?.removePanelFromParent(animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                self.natigationBarItem.title = self.document?.fileURL.lastPathComponent.stripFileExtension()
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
                self.pdfView.backgroundColor = UIColor.gray
                self.pdfView.autoScales = true
                guard let url = self.document?.fileURL else {fatalError("INVALID URL")}
                self.pdf = PDFDocument(url: url)
                let cgPDF = CGPDFDocument((url as CFURL))
                if let pdfPage = cgPDF!.page(at: 1) {
                    let mediaBox = pdfPage.getBoxRect(.mediaBox)
//                    print(mediaBox)
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
//                for i in 1...cgPDF!.numberOfPages {
//                    if let pdfPage = cgPDF!.page(at: i) {
//                        let mediaBox = pdfPage.getBoxRect(.mediaBox)
////                        print(mediaBox)
//                        let angle = CGFloat(pdfPage.rotationAngle) * CGFloat.pi / 180
//                        let rotatedBox = mediaBox.applying(CGAffineTransform(rotationAngle: angle))
//                        self.nativeSizesForPDF.append((Float(rotatedBox.width), Float(rotatedBox.height)))
//                    }
//                }
            } else {
                print("Failed to load PDF document")
            }
        })

        dimensionPicker.dataSource = self
        dimensionPicker.delegate = self
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
                self.navigationDoneButton.isEnabled = true
                self.colorPickerButton.isEnabled = true
                self.dimensionPicker.isUserInteractionEnabled = true
                self.startConversionButton.isEnabled = true
                self.customizeAspectRatioButton.isEnabled = true
                self.startConversionButton.backgroundColor = UIColor(red: 0.3882352941, green: 0.7058823529, blue: 0.8431372549, alpha: 1)
            } else {
                self.navigationDoneButton.isEnabled = false
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

    func stringForTextFileName(_ name: String) -> String {
        if let filepath = Bundle.main.path(forResource: name, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return ""
            }
        } else {
            return ""
        }
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

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
