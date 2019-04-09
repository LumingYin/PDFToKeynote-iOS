//
//  ConfigurationViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/8/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import PDFKit
import FloatingPanel

typealias SlideSize = (width: Int, height: Int, description: String)

class ConfigurationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChromaColorPickerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource, SlideSizeDelegate {

    @IBOutlet weak var customizeImageView: UIImageView!
    @IBOutlet weak var startConversionButton: UIButton!
    @IBOutlet weak var dimensionPicker: UIPickerView!
    @IBOutlet weak var aspectRatioLabel: UILabel!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var customizeAspectRatioButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var pdf: PDFDocument!
    weak var document: UIDocument?
    var enableDisableStateChanged: ((Bool) -> ())?
    var moveToPosition: (() -> ())?
    var neatColorPicker: ChromaColorPicker!

    var selectedColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            colorPickerButton.backgroundColor = selectedColor
        }
    }
//    var selectedRow: Int {
//        get {
//            return self.dimensionPicker.selectedRow(inComponent: 0)
//        }
//    }

    var sizes: [SlideSize] = [
        (1920, 1080, "16:9"),
        (1680, 1050, "16:10"),
        (1024, 768, "4:3"),
        (1280, 1024, "5:4"),
//        (768, 1024, "3:4"),
//        (1080, 1920, "9:16"),
//        (1050, 1680, "10:16"),
        (612, 792, "Letter\nPortrait"),
        (792, 612, "Letter\nLandscape"),
        (595, 842, "A4\nPortrait"),
        (842, 595, "A4\nLandscape")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startConversionButton.setTitleColor(UIColor.darkGray, for: .disabled)
        let image = UIImage(named: "Settings")!.withRenderingMode(.alwaysTemplate)
        customizeImageView.image = image
        customizeImageView.tintColor = UIColor(named: "customBlue")
        tableView.delegate = self
        tableView.dataSource = self
        // dimensionPicker.dataSource = self
        // dimensionPicker.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.section
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileInformationTableViewCell", for: indexPath) as! FileInformationTableViewCell
            cell.documentNameLabel.text = cachedFileName
            cell.documentResolutionLabel.text = cachedFileResulution
            cell.documentSizeLabel.text = cachedFileSize
            cell.documentPageCountLabel.text = cachedPageCount
            return cell
        } else if row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SlideSizeTableViewCell", for: indexPath) as! SlideSizeTableViewCell
            cell.configurateCollectionView()
            cell.delegate = self
            return cell
        } else if row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundColorTableViewCell", for: indexPath) as! BackgroundColorTableViewCell
            cell.configurateCollectionView()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileInformationTableViewCell", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.section
        if row == 0 {
            return 130
        } else if row == 1 {
            return 268
        } else if row == 2 {
            return 268
        }
        return 200
    }

    // File information
    var cachedFileName: String = "Unknown"
    var cachedFileResulution: String = "Unknown"
    var cachedFileSize: String = "Unknown"
    var cachedPageCount: String = "? page"

    // Size information
    var nativeSizeIndex: Int = 0
    var selectedSizeIndex: Int = 0
    var useRetina2x: Bool = false

    func updateParticularCollectionViewIndex(i: Int, native: Bool, selected: Bool) {
        guard let sizeCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SlideSizeTableViewCell else { return }
        let path = ConfigurationViewController.findIndexPathForResolutionIndex(i: i, delegate: self)
        guard let asp = sizeCell.collectionView.cellForItem(at: path) as? AspectRatioCollectionViewCell else { return }
        if native {
            asp.configurateAsNativeSize()
        }
        if selected {
            asp.selectSizeTapped(self)
        }
//        asp.configurateCellAppearance()
    }

    static func findIndexPathForResolutionIndex(i: Int, delegate: SlideSizeDelegate) -> IndexPath {
        let correctedI = i >= delegate.getCutoffCountForScreenResolution() ? i - delegate.getCutoffCountForScreenResolution() : i
        let section = i >= delegate.getCutoffCountForScreenResolution() ? 1 : 0
        let path = IndexPath(row: correctedI, section: section)
        return path
    }

    func initialSetupForPDF(_ newDocument: Document) {
        self.document = newDocument
        cachedFileName = self.document?.fileURL.lastPathComponent ?? "Unknown"
        guard let url = self.document?.fileURL else {fatalError("INVALID URL")}
        self.pdf = PDFDocument(url: url)
        let cgPDF = CGPDFDocument((url as CFURL))
        let pageCount = cgPDF?.numberOfPages ?? 0
        cachedPageCount = "\(pageCount) \(pageCount > 1 ? "pages" : "page")"
        if let pdfPage = cgPDF!.page(at: 1) {
            let mediaBox = pdfPage.getBoxRect(.mediaBox)
            // print(mediaBox)
            let angle = CGFloat(pdfPage.rotationAngle) * CGFloat.pi / 180
            let rotatedBox = mediaBox.applying(CGAffineTransform(rotationAngle: angle))
            cachedFileResulution = "\(Int(rotatedBox.width)) × \(Int(rotatedBox.height))"
            let ratio = Float(rotatedBox.width / rotatedBox.height)
            var matchedPreferredResolutions = false
            for i in 0..<self.sizes.count {
                let size = self.sizes[i]
                let sizeRatio = Float(size.width) / Float(size.height)
                if abs(ratio - sizeRatio) < 0.01 {
                    self.sizes[i].description = "\(self.sizes[i].description) (Native)"
                    self.nativeSizeIndex = i
                    self.selectSizeAtIndex(index: i)
                    self.updateParticularCollectionViewIndex(i: i, native: true, selected: true)
//                    self.dimensionPicker.selectRow(i, inComponent: 0, animated: true)
//                    self.aspectRatioLabel.text = self.sizes[i].description
                    matchedPreferredResolutions = true
                    break
                }
            }
            if !matchedPreferredResolutions {
                let factor = max(1024 / rotatedBox.width, 768 / rotatedBox.height)
                // print("Scale factor is: \(factor)")
                let newWidth = rotatedBox.width * CGFloat(factor)
                let newHeight = rotatedBox.height * CGFloat(factor)
                self.addNewSize(width: Int(newWidth), height: Int(newHeight), description: "\(Int(newWidth))\n\(Int(newHeight))")
                self.nativeSizeIndex = self.sizes.count - 1
                self.selectSizeAtIndex(index: self.nativeSizeIndex)
                self.updateParticularCollectionViewIndex(i: self.nativeSizeIndex, native: true, selected: true)

//                self.selectedSizeIndex = self.nativeSizeIndex
//                self.dimensionPicker.reloadComponent(0)
//                self.dimensionPicker.selectRow(self.sizes.count - 1, inComponent: 0, animated: true)
//                self.aspectRatioLabel.text = self.sizes.last?.description
            }
        }
        cachedFileSize = url.fileSizeString
        tableView.reloadData()
//        tableView.reloadRows(at: [IndexPath(row: 0, column: 0)], with: .automatic)
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
        let cachedRow = self.selectedSizeIndex
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
//                self.colorPickerButton.isEnabled = true
//                self.dimensionPicker.isUserInteractionEnabled = true
                self.startConversionButton.isEnabled = true
//                self.customizeAspectRatioButton.isEnabled = true
                self.startConversionButton.backgroundColor = UIColor(red: 0.3882352941, green: 0.7058823529, blue: 0.8431372549, alpha: 1)
            } else {
                self.enableDisableStateChanged?(false)
//                self.colorPickerButton.isEnabled = false
//                self.dimensionPicker.isUserInteractionEnabled = false
                self.startConversionButton.isEnabled = false
                self.startConversionButton.backgroundColor = UIColor.gray
//                self.customizeAspectRatioButton.isEnabled = false
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

//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        aspectRatioLabel.text = sizes[selectedRow].description
//    }

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

    @IBAction func customizeButtonTapped(_ sender: Any) {
        moveToPosition?()
    }
    
//    @IBAction func addNewAspectRatioTapped(_ sender: UIButton) {
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyBoard.instantiateViewController(withIdentifier: "AddWidthHeight") as! AddWidthHeightViewController
//        controller.newSizeAdded = { (width, height) in
//            self.sizes.append((width, height, "Custom: \(width) × \(height)"))
//            self.dimensionPicker.reloadComponent(0)
//            self.dimensionPicker.selectRow(self.sizes.count - 1, inComponent: 0, animated: true)
//            self.aspectRatioLabel.text = self.sizes[self.selectedRow].description
//        }
//        controller.modalPresentationStyle = .popover
//        controller.preferredContentSize = CGSize(width: 300, height: 200)
//        let presentationController = controller.presentationController as! UIPopoverPresentationController
//        presentationController.backgroundColor = controller.view.backgroundColor
//        presentationController.delegate = self
//        presentationController.sourceView = sender
//        presentationController.sourceRect = sender.bounds
//        presentationController.permittedArrowDirections = [.down, .up]
//        self.present(controller, animated: true)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - SlideSizeDelegate
    func getAllSizes() -> [SlideSize] {
        return self.sizes
    }

    func getNativeSizeIndex() -> Int {
        return self.nativeSizeIndex
    }

    func getSelectedSizeIndex() -> Int {
        return self.selectedSizeIndex
    }

    func addNewSize(width: Int, height: Int, description: String) {
        self.sizes.append((width, height, description))
        self.tableView.reloadData()
    }

    func addNewSize(width: Int, height: Int) {
        self.addNewSize(width: width, height: height, description: "Custom")
    }

    func selectSizeAtIndex(index: Int) {
        self.selectedSizeIndex = index
    }

    func setShouldUseRetina2x(shouldUse: Bool) {
        self.useRetina2x = shouldUse
    }

    func getUsingRetina2x() -> Bool {
        return self.useRetina2x
    }

    func getCutoffCountForScreenResolution() -> Int {
        return 4
    }
}

protocol SlideSizeDelegate : class {
    func getAllSizes() -> [SlideSize]
    func getNativeSizeIndex() -> Int
    func getSelectedSizeIndex() -> Int
    func getUsingRetina2x() -> Bool
    func addNewSize(width: Int, height: Int)
    func addNewSize(width: Int, height: Int, description: String)
    func selectSizeAtIndex(index: Int)
    func setShouldUseRetina2x(shouldUse: Bool)
    func getCutoffCountForScreenResolution() -> Int
}
