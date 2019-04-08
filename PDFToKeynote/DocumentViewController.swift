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

class DocumentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChromaColorPickerDelegate {
    @IBOutlet weak var startConversionButton: UIButton!
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var dimensionPicker: UIPickerView!
    @IBOutlet weak var aspectRatioLabel: UILabel!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var colorPickerButton: UIButton!
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
    var nativeSizesForPDF: [(width: Float, height: Float)] = []

    override func viewDidLoad() {
        self.startConversionButton.setTitleColor(UIColor.darkGray, for: .disabled)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
                self.pdfView.backgroundColor = UIColor.gray
                self.pdfView.autoScales = true
                guard let url = self.document?.fileURL else {fatalError("INVALID URL")}
                self.pdf = PDFDocument(url: url)
                let cgPDF = CGPDFDocument((url as CFURL))
                if let pdfPage = cgPDF!.page(at: 1) {
                    let mediaBox = pdfPage.getBoxRect(.mediaBox)
                    print(mediaBox)
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
                        print("Scale factor is: \(factor)")
                        let newWidth = rotatedBox.width * CGFloat(factor)
                        let newHeight = rotatedBox.height * CGFloat(factor)
                        self.sizes.append((Int(newWidth), Int(newHeight), "Native Resolution"))
                        self.dimensionPicker.reloadComponent(0)
                        self.dimensionPicker.selectRow(self.sizes.count - 1, inComponent: 0, animated: true)
                        self.aspectRatioLabel.text = self.sizes.last?.description
                    }
                }
                for i in 1...cgPDF!.numberOfPages {
                    if let pdfPage = cgPDF!.page(at: i) {
                        let mediaBox = pdfPage.getBoxRect(.mediaBox)
                        print(mediaBox)
                        let angle = CGFloat(pdfPage.rotationAngle) * CGFloat.pi / 180
                        let rotatedBox = mediaBox.applying(CGAffineTransform(rotationAngle: angle))
                        self.nativeSizesForPDF.append((Float(rotatedBox.width), Float(rotatedBox.height)))
                    }
                }
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
        guard let totalPages = pdf?.pageCount else {return}
        let uuid = NSUUID().uuidString
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

        for count in 0..<totalPages {
            let progress = (Float(count + 1) / Float(totalPages)) * 0.3
            SVProgressHUD.showProgress(Float(progress), status: "Extracting PDF:\n\(count + 1) of \(totalPages)")
            if let page = pdf?.page(at: count) {
                let document = PDFDocument()
                document.insert(page, at: 0)
                let data = document.dataRepresentation()
                do {
                    try FileManager.default.createDirectory(atPath: "\(cachePath)/\(uuid)", withIntermediateDirectories: true, attributes: nil)
                    let pageString = String(format: "pg_%04d.pdf", (count + 1))
                    let url = URL(fileURLWithPath: "\(cachePath)/\(uuid)/\(pageString)")
                    try data?.write(to: url)
                } catch {
                    print(error)
                }
            }
        }

        var templateBeginning = stringForTextFileName("template_beginning")
        let templateContent = stringForTextFileName("template_content")
        let templateEnding = stringForTextFileName("template_ending")

        var actualContent = ""
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSWIDTHxxx", with: "\(sizes[selectedRow].width)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSHEIGHTxxx", with: "\(sizes[selectedRow].height)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGREDxxx", with: "\(selectedColor.rgba.red)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGGREENxxx", with: "\(selectedColor.rgba.green)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGBLUExxx", with: "\(selectedColor.rgba.blue)")

        var sfaIDCachedDict: [String : Int] = [:]

        do {
            for count in 0..<totalPages {
                let progress = 0.3 + 0.3 * (Double(count + 1) / Double(totalPages))
                SVProgressHUD.showProgress(Float(progress), status: "Parsing Slide:\n\(count + 1) of \(totalPages)")

                var oldNewRamap: [String : String] = [:]

                var pageContent = String(templateContent)
                let formattedNaturalWidth = String(format: "%06f", nativeSizesForPDF[count].width)
                let formattedNaturalHeight = String(format: "%06f", nativeSizesForPDF[count].height)

                pageContent = pageContent.replacingOccurrences(of: "xxxNWIDTHxxx", with: formattedNaturalWidth)
                pageContent = pageContent.replacingOccurrences(of: "xxxNHEIGHTxxx", with: formattedNaturalHeight)

                let (finalWidth, finalHeight, offsetX, offsetY) = fitSizeIntoSlide(pdfWidth: nativeSizesForPDF[count].width, pdfHeight: nativeSizesForPDF[count].height, canvasWidth: sizes[selectedRow].width, canvasHeight: sizes[selectedRow].height)
                pageContent = pageContent.replacingOccurrences(of: "xxxDWIDTHxxx", with: String(format: "%06f", finalWidth))
                pageContent = pageContent.replacingOccurrences(of: "xxxDHEIGHTxxx", with: String(format: "%06f", finalHeight))
                pageContent = pageContent.replacingOccurrences(of: "xxxPOSXxxx", with: String(format: "%06f", offsetX))
                pageContent = pageContent.replacingOccurrences(of: "xxxPOSYxxx", with: String(format: "%06f", offsetY))

                var eachLine = pageContent.components(separatedBy: .newlines)
                for i in 0..<eachLine.count {
                    let lineContent = eachLine[i]
                    let pattern = #"(sfa:ID="((\D+?)-\d+)")"#
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    if let match = regex.firstMatch(in: lineContent, range: NSRange(lineContent.startIndex..., in: lineContent)) {
                        // let entireSFAPart = String(lineContent[Range(match.range(at: 1), in: lineContent)!])
                        let sfaInnerQuote = String(lineContent[Range(match.range(at: 2), in: lineContent)!])
                        let sfaActualType = String(lineContent[Range(match.range(at: 3), in: lineContent)!])
                        // print("entireSFAPart: \(entireSFAPart), sfaInnerQuote: \(sfaInnerQuote), sfaActualType: \(sfaActualType)")
                        if sfaIDCachedDict[sfaActualType] == nil {
                            sfaIDCachedDict[sfaActualType] = 1000
                        } else {
                            sfaIDCachedDict[sfaActualType] = sfaIDCachedDict[sfaActualType]! + 1
                        }
                        let newIndex = "\(sfaActualType)-\(sfaIDCachedDict[sfaActualType]!)"
                        let reconstructedIndex = "sfa:ID=\"\(newIndex)\""
                        let replacementRange = NSMakeRange(0, lineContent.count)
                        let modString = regex.stringByReplacingMatches(in: lineContent, options: [], range: replacementRange, withTemplate: reconstructedIndex) // reconstructedIndex is not a template
                        oldNewRamap[sfaInnerQuote] = newIndex
                        eachLine[i] = modString
                    }
                }

                var rejoined = eachLine.joined(separator: "\n")
                for (old, new) in oldNewRamap {
                    rejoined = rejoined.replacingOccurrences(of: "\"\(old)\"", with: "\"\(new)\"")
                }

                let pageString = String(format: "pg_%04d.pdf", (count + 1))
                rejoined = rejoined.replacingOccurrences(of: "xxxFILENAMExxx", with: pageString)
                actualContent = "\(actualContent)\(rejoined)"
            }
        } catch {
            print(error)
        }


        let finalText = "\(templateBeginning)\(actualContent)\(templateEnding)"
        do {
            try finalText.write(to: URL(fileURLWithPath: "\(cachePath)/\(uuid)/index.apxl"), atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }

        do {
            Zip.addCustomFileExtension("key")
            let fileName = "\(self.document?.fileURL.lastPathComponent.stripFileExtension() ?? "exported-\(uuid)")"
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let destinationUrl = documentsUrl.appendingPathComponent("\(fileName).key")
            try Zip.zipFiles(paths: [URL(fileURLWithPath: "\(cachePath)/\(uuid)", isDirectory: false)], zipFilePath: destinationUrl, password: nil, progress: { (progress: Double) in
                SVProgressHUD.showProgress(Float(0.6 + 0.3 * progress), status: "Exporting Keynote File:\n\(Int(Double(totalPages) * progress)) of \(totalPages)")
            })

            try FileManager.default.removeItem(atPath: "\(cachePath)/\(uuid)")
            var filesToShare = [Any]()
            filesToShare.append(destinationUrl)

            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.startConversionButton
                self.setConversionActivationState(active: true)
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        catch {
            print("Something went wrong: \(error)")
        }
        self.setConversionActivationState(active: true)
    }

    func setConversionActivationState(active: Bool) {
        DispatchQueue.main.async {
            if (active) {
                SVProgressHUD.dismiss()
                self.colorPickerButton.isEnabled = true
                self.dimensionPicker.isUserInteractionEnabled = true
                self.startConversionButton.isEnabled = true
                self.startConversionButton.backgroundColor = UIColor(red: 0.3882352941, green: 0.7058823529, blue: 0.8431372549, alpha: 1)
            } else {
                self.colorPickerButton.isEnabled = false
                self.dimensionPicker.isUserInteractionEnabled = false
                self.startConversionButton.isEnabled = false
                self.startConversionButton.backgroundColor = UIColor.gray
            }
        }
    }

    func fitSizeIntoSlide(pdfWidth: Float, pdfHeight: Float, canvasWidth: Int, canvasHeight: Int) -> (fittingWidth: Float, fittingHeight: Float, originX: Float, originY: Float) {
        let displayWidthRatio = Float(canvasWidth) / pdfWidth
        let displayHeightRatio = Float(canvasHeight) / pdfHeight
        let zoomShrinkFactor = min(displayWidthRatio, displayHeightRatio)
        let finalWidth = pdfWidth * zoomShrinkFactor
        let finalHeight = pdfHeight * zoomShrinkFactor
        let x = (Float(canvasWidth) - finalWidth) / 2
        let y = (Float(canvasHeight) - finalHeight) / 2
        return (finalWidth, finalHeight, x, y)
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
        let controller = UIViewController()
        controller.view = neatColorPicker
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 300, height: 300)
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.sourceView = sender
        presentationController.sourceRect = sender.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }

    @objc func colorChanged(_ colorPicker: ChromaColorPicker) {
        selectedColor = colorPicker.currentColor
    }

    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        selectedColor = color
    }

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
