//
//  DocumentViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/7/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit
import PDFKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }

    @IBAction func startConversion(_ sender: Any) {
        guard let url = self.document?.fileURL else {fatalError("INVALID URL")}
        let pdf = PDFDocument(url: url)
        guard let count = pdf?.pageCount else {return}
        let uuid = NSUUID().uuidString
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        for count in 0..<count {
            if let page = pdf?.page(at: count) {
                let document = PDFDocument()
                document.insert(page, at: 0)
                let data = document.dataRepresentation()
                do {
                    try FileManager.default.createDirectory(atPath: "\(documentsPath)/\(uuid)", withIntermediateDirectories: true, attributes: nil)
                    let pageString = String(format: "pg_%04d.pdf", (count + 1))
                    let url = URL(fileURLWithPath: "\(documentsPath)/\(uuid)/\(pageString)")
                    try data?.write(to: url)
                } catch {
                    print(error)
                }
            }
        }
        var templateBeginning = stringForTextFileName("template_beginning")
        var templateContent = stringForTextFileName("template_content")
        var templateEnding = stringForTextFileName("template_ending")
//        print(templateEnding)

        var actualContent = ""
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSWIDTHxxx", with: "1024")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSHEIGHTxxx", with: "768")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGREDxxx", with: "0.99989223480224609")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGGREENxxx", with: "0.99998199939727783")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGBLUExxx", with: "0.99983745813369751")

        templateContent = templateContent.replacingOccurrences(of: "xxxNWIDTHxxx", with: "1024")
        templateContent = templateContent.replacingOccurrences(of: "xxxNHEIGHTxxx", with: "768")
        templateContent = templateContent.replacingOccurrences(of: "xxxDWIDTHxxx", with: "1024")
        templateContent = templateContent.replacingOccurrences(of: "xxxDHEIGHTxxx", with: "768")
        templateContent = templateContent.replacingOccurrences(of: "xxxPOSXxxx", with: "0")
        templateContent = templateContent.replacingOccurrences(of: "xxxPOSYxxx", with: "0")

        var sfaIDCachedDict: [String : Int] = [:]

        do {
            for count in 0..<count {
                var oldNewRamap: [String : String] = [:]

                var pageContent = templateContent
                var eachLine = pageContent.components(separatedBy: .newlines)
                for i in 0..<eachLine.count {
                    let lineContent = eachLine[i]
                    let pattern = #"(sfa:ID="((\D+?)-\d+)")"#
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    if let match = regex.firstMatch(in: lineContent, range: NSRange(lineContent.startIndex..., in: lineContent)) {
                        let entireSFAPart = String(lineContent[Range(match.range(at: 1), in: lineContent)!])
                        let sfaInnerQuote = String(lineContent[Range(match.range(at: 2), in: lineContent)!])
                        let sfaActualType = String(lineContent[Range(match.range(at: 3), in: lineContent)!])

                        print("entireSFAPart: \(entireSFAPart), sfaInnerQuote: \(sfaInnerQuote), sfaActualType: \(sfaActualType)")
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


        var finalText = "\(templateBeginning)\(actualContent)\(templateEnding)"
//        print(finalText)
        do {
//            try templateBeginning.write(to: URL(fileURLWithPath: "\(documentsPath)/\(uuid)/wth1.txt"), atomically: true, encoding: .utf8)
//            try actualContent.write(to: URL(fileURLWithPath: "\(documentsPath)/\(uuid)/wth2.txt"), atomically: true, encoding: .utf8)
//            try templateEnding.write(to: URL(fileURLWithPath: "\(documentsPath)/\(uuid)/wth3.txt"), atomically: true, encoding: .utf8)
            try finalText.write(to: URL(fileURLWithPath: "\(documentsPath)/\(uuid)/index.apxl"), atomically: true, encoding: .utf8)
        } catch {
            print(error)
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
