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

class DocumentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedRow = 0
    var sizes: [(width: Int, height: Int, description: String)] = [
        (1024, 768, "4:3 XGA"),
        (1280, 720, "16:9 HDTV"),
        (1280, 800, "16:10 MacBook"),
        (1280, 1024, "5:4 SXGA"),
        (1600, 1200, "4:3 UXGA"),
        (1680, 1050, "16:10 WSXGA+"),
        (1920, 1080, "16:9 WUXGA/HDTV"),
        (612, 792, "US Letter (Portrait)"),
        (792, 612, "US Letter (Landscape)"),
        (595, 842, "A4 Paper (Portrait)"),
        (842, 595, "A4 Paper (Landscape)"),
        (800, 600, "4:3 SVGA"),
    ]

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
        //        return "\(width) × \(height) - \(description)"
        let string = "\(width) × \(height)"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        aspectRatioLabel.text = sizes[selectedRow].description
    }

    
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var dimensionPicker: UIPickerView!
    @IBOutlet weak var aspectRatioLabel: UILabel!
    @IBOutlet weak var pdfView: PDFView!
    var pdf: PDFDocument!

    @IBOutlet weak var startConversionButton: UIButton!
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
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
                    for i in 0..<self.sizes.count {
                        let size = self.sizes[i]
                        let sizeRatio = Float(size.width) / Float(size.height)
                        if abs(ratio - sizeRatio) < 0.01 {
                            self.dimensionPicker.selectRow(i, inComponent: 0, animated: true)
                            self.selectedRow = i
                            self.aspectRatioLabel.text = size.description
                            break
                        }
                    }
                }
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })

        dimensionPicker.dataSource = self
        dimensionPicker.delegate = self
    }

    @IBAction func startConversion(_ sender: Any) {
        guard let count = pdf?.pageCount else {return}
        let uuid = NSUUID().uuidString
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

        for count in 0..<count {
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
        var templateContent = stringForTextFileName("template_content")
        let templateEnding = stringForTextFileName("template_ending")

        var actualContent = ""
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSWIDTHxxx", with: "\(sizes[selectedRow].width)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSHEIGHTxxx", with: "\(sizes[selectedRow].height)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGREDxxx", with: "0.99989223480224609")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGGREENxxx", with: "0.99998199939727783")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGBLUExxx", with: "0.99983745813369751")

        templateContent = templateContent.replacingOccurrences(of: "xxxNWIDTHxxx", with: "\(sizes[selectedRow].width)")
        templateContent = templateContent.replacingOccurrences(of: "xxxNHEIGHTxxx", with: "\(sizes[selectedRow].height)")
        templateContent = templateContent.replacingOccurrences(of: "xxxDWIDTHxxx", with: "\(sizes[selectedRow].width)")
        templateContent = templateContent.replacingOccurrences(of: "xxxDHEIGHTxxx", with: "\(sizes[selectedRow].height)")
        templateContent = templateContent.replacingOccurrences(of: "xxxPOSXxxx", with: "0")
        templateContent = templateContent.replacingOccurrences(of: "xxxPOSYxxx", with: "0")

        var sfaIDCachedDict: [String : Int] = [:]

        do {
            for count in 0..<count {
                var oldNewRamap: [String : String] = [:]

                let pageContent = templateContent
                var eachLine = pageContent.components(separatedBy: .newlines)
                for i in 0..<eachLine.count {
                    let lineContent = eachLine[i]
                    let pattern = #"(sfa:ID="((\D+?)-\d+)")"#
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    if let match = regex.firstMatch(in: lineContent, range: NSRange(lineContent.startIndex..., in: lineContent)) {
//                        let entireSFAPart = String(lineContent[Range(match.range(at: 1), in: lineContent)!])
                        let sfaInnerQuote = String(lineContent[Range(match.range(at: 2), in: lineContent)!])
                        let sfaActualType = String(lineContent[Range(match.range(at: 3), in: lineContent)!])

//                        print("entireSFAPart: \(entireSFAPart), sfaInnerQuote: \(sfaInnerQuote), sfaActualType: \(sfaActualType)")
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
            try Zip.zipFiles(paths: [URL(fileURLWithPath: "\(cachePath)/\(uuid)", isDirectory: false)], zipFilePath: destinationUrl, password: nil, progress: nil)

            try FileManager.default.removeItem(atPath: "\(cachePath)/\(uuid)")

            var filesToShare = [Any]()
            filesToShare.append(destinationUrl)
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.startConversionButton
            self.present(activityViewController, animated: true, completion: nil)

        }
        catch {
            print("Something went wrong: \(error)")
        }
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

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
