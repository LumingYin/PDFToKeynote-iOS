//
//  Converter.swift
//  
//
//  Created by Blue on 4/8/19.
//

import UIKit
import PDFKit
import Zip
import CoreGraphics

class Converter: NSObject {

    static func calculateNativeSizesForPDF(url: URL) -> [(width: Float, height: Float, angle: Int)] {
        var nativeSizesForPDF: [(width: Float, height: Float, angle: Int)] = []
        let cgPDF = CGPDFDocument((url as CFURL))
        for i in 1...cgPDF!.numberOfPages {
            if let pdfPage = cgPDF!.page(at: i) {
                let mediaBox = pdfPage.getBoxRect(.mediaBox)
                // print(mediaBox)
                let angle = CGFloat(pdfPage.rotationAngle) * CGFloat.pi / 180
                let rotatedBox = mediaBox.applying(CGAffineTransform(rotationAngle: angle))
                nativeSizesForPDF.append((Float(rotatedBox.width), Float(rotatedBox.height), Int(pdfPage.rotationAngle)))
            }
        }
        return nativeSizesForPDF
    }

    static func performConversion(pdf: PDFDocument?, selectedSize: (width: Int, height: Int, description: String), selectedColor: UIColor, pdfFileName: String?, conversionSucceededCallback : ((_ outputURL: URL)->(Void))?, conversionEndedCallback : (()->(Void))?) {
        guard let totalPages = pdf?.pageCount else {return}
        let nativeSizesForPDF = calculateNativeSizesForPDF(url: (pdf?.documentURL!)!)
        let uuid = NSUUID().uuidString
        // let cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

        let cgPDF = CGPDFDocument(((pdf?.documentURL!)! as CFURL))
        do {try FileManager.default.createDirectory(atPath: "\(cachePath)/\(uuid)", withIntermediateDirectories: true, attributes: nil)} catch {}
        let provider = CGDataProvider(url: ((pdf?.documentURL!)! as CFURL))!
        for count in 1..<cgPDF!.numberOfPages + 1 {
            let document = CGPDFDocument(provider)!
            let page = document.page(at: count)!
            let rotation = page.rotationAngle
            var origBoxRect = page.getBoxRect(.mediaBox)
            var destinationBoxRect = page.getBoxRect(.mediaBox)
            if (rotation == 90 || rotation == 270) {
                destinationBoxRect = CGRect(x: destinationBoxRect.origin.x, y: destinationBoxRect.origin.y, width: destinationBoxRect.height, height: destinationBoxRect.width)
            }
            let pageString = String(format: "pg_%04d.pdf", count)
            let path = URL(fileURLWithPath: "\(cachePath)/\(uuid)/\(pageString)")
            let urlContext = CGContext(path as CFURL, mediaBox: &origBoxRect, nil)
            urlContext?.beginPage(mediaBox: &destinationBoxRect)
            let transform = page.getDrawingTransform(.mediaBox, rect: destinationBoxRect, rotate: 0, preserveAspectRatio: true)
            urlContext?.concatenate(transform)
            urlContext?.drawPDFPage(page)
            urlContext?.endPage()
            urlContext?.flush()
        }

        var templateBeginning = String.stringForTextFileName("template_beginning")
        let templateContent = String.stringForTextFileName("template_content")
        let templateEnding = String.stringForTextFileName("template_ending")

        var actualContent = ""
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSWIDTHxxx", with: "\(selectedSize.width)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxSHEIGHTxxx", with: "\(selectedSize.height)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGREDxxx", with: "\(selectedColor.rgba.red)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGGREENxxx", with: "\(selectedColor.rgba.green)")
        templateBeginning = templateBeginning.replacingOccurrences(of: "xxxBGBLUExxx", with: "\(selectedColor.rgba.blue)")

        var sfaIDCachedDict: [String : Int] = [:]

        do {
            for count in 0..<totalPages {
                let progress = 0.3 + 0.3 * (Double(count + 1) / Double(totalPages))
                SVProgressHUD.showProgress(Float(progress), status: "Parsing PDF:\n\(count + 1) of \(totalPages)")

                var oldNewRamap: [String : String] = [:]

                var pageContent = String(templateContent)
                let formattedNaturalWidth = String(format: "%06f", nativeSizesForPDF[count].width)
                let formattedNaturalHeight = String(format: "%06f", nativeSizesForPDF[count].height)

                pageContent = pageContent.replacingOccurrences(of: "xxxNWIDTHxxx", with: formattedNaturalWidth)
                pageContent = pageContent.replacingOccurrences(of: "xxxNHEIGHTxxx", with: formattedNaturalHeight)

                let (finalWidth, finalHeight, offsetX, offsetY) = fitSizeIntoSlide(pdfWidth: nativeSizesForPDF[count].width, pdfHeight: nativeSizesForPDF[count].height, angle: nativeSizesForPDF[count].angle, canvasWidth: selectedSize.width, canvasHeight: selectedSize.height, scale: 1)
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
            let fileName = "\(pdfFileName ?? "exported-\(uuid)")"
            let fileManager = FileManager.default
            let cachesUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0] as URL
            let destinationUrl = cachesUrl.appendingPathComponent("\(fileName).key")
            try Zip.zipFiles(paths: [URL(fileURLWithPath: "\(cachePath)/\(uuid)", isDirectory: false)], zipFilePath: destinationUrl, password: nil, progress: { (progress: Double) in
                SVProgressHUD.showProgress(Float(0.6 + 0.3 * progress), status: "Exporting Keynote File:\n\(Int(Double(totalPages) * progress)) of \(totalPages)")
            })

            try FileManager.default.removeItem(atPath: "\(cachePath)/\(uuid)")

            DispatchQueue.main.async {
                conversionSucceededCallback?(destinationUrl)
            }
        }
        catch {
            print("Something went wrong: \(error)")
        }
        conversionEndedCallback?()
    }

    static func swapWithoutTuples(_ a: inout Float, _ b: inout Float) {
        let temporaryA = a
        a = b
        b = temporaryA
    }

    static func fitSizeIntoSlide(pdfWidth: Float, pdfHeight: Float, angle: Int, canvasWidth: Int, canvasHeight: Int, scale: Float) -> (fittingWidth: Float, fittingHeight: Float, originX: Float, originY: Float) {
        let displayWidthRatio = Float(canvasWidth) / pdfWidth
        let displayHeightRatio = Float(canvasHeight) / pdfHeight
        let zoomShrinkFactor = min(displayWidthRatio, displayHeightRatio)
        let finalWidth = pdfWidth * zoomShrinkFactor
        let finalHeight = pdfHeight * zoomShrinkFactor
        let x = (Float(canvasWidth) - finalWidth) / 2
        let y = (Float(canvasHeight) - finalHeight) / 2
        return (finalWidth, finalHeight, x, y)
    }

}
