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
                //                        print(mediaBox)
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
//        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

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
//                var width = boxRect.width
//                var height = boxRect.height
                destinationBoxRect = CGRect(x: destinationBoxRect.origin.x, y: destinationBoxRect.origin.y, width: destinationBoxRect.height, height: destinationBoxRect.width)
//                boxRect.height = width
//                boxRect.width = height
            } else {

            }
            let pageString = String(format: "pg_%04d.pdf", count)
            let path = URL(fileURLWithPath: "\(cachePath)/\(uuid)/\(pageString)")
            let urlContext = CGContext(path as CFURL, mediaBox: &origBoxRect, nil)
            let dictionary = page.dictionary
            urlContext?.beginPage(mediaBox: &destinationBoxRect)
            // eax = [self sizingPDFBox];
            let transform = page.getDrawingTransform(.mediaBox, rect: destinationBoxRect, rotate: 0, preserveAspectRatio: true)
            urlContext?.concatenate(transform)
            // [self croppingPDFBox];

//            let newBoxRect = page.getBoxRect(.mediaBox)
//            urlContext?.clip(to: boxRect)

//            let appliedNewRect = boxRect.applying(transform)
//            urlContext?.clip(to: appliedNewRect)
            urlContext?.drawPDFPage(page)
            urlContext?.endPage()
            urlContext?.flush()


        }

//        let cgPDF = CGPDFDocument(((pdf?.documentURL!)! as CFURL))
//        for count in 1..<cgPDF!.numberOfPages + 1 {
//            let progress = (Float(count + 1) / Float(totalPages)) * 0.3
//            SVProgressHUD.showProgress(Float(progress), status: "Extracting PDF:\n\(count) of \(totalPages)")
//            do {
//                if let pdfPage = cgPDF!.page(at: count) {
//                    try FileManager.default.createDirectory(atPath: "\(cachePath)/\(uuid)", withIntermediateDirectories: true, attributes: nil)
//                    let pageString = String(format: "pg_%04d.pdf", count)
//                    let urlString = "\(cachePath)/\(uuid)/\(pageString)"
//                    //                let url = URL(fileURLWithPath: "\(cachePath)/\(uuid)/\(pageString)")
//
//                    UIGraphicsBeginPDFContextToFile(urlString, CGRect.zero, nil)
//                    var context = UIGraphicsGetCurrentContext()
//                    PDFPageRenderer.renderPage(pdfPage, in: context)
//                    UIGraphicsEndPDFContext()
//                }
//            } catch {
//                print("\(error)")
//            }
//        }


//        for count in 0..<totalPages {
//            let progress = (Float(count + 1) / Float(totalPages)) * 0.3
//            SVProgressHUD.showProgress(Float(progress), status: "Extracting PDF:\n\(count + 1) of \(totalPages)")
//            if let page = pdf?.page(at: count) {
////                page.rotation = 0 // would this work
//                let document = PDFDocument()
//                document.insert(page, at: 0)
//                let data = document.dataRepresentation()
//                do {
//                    try FileManager.default.createDirectory(atPath: "\(cachePath)/\(uuid)", withIntermediateDirectories: true, attributes: nil)
//                    let pageString = String(format: "pg_%04d.pdf", (count + 1))
//                    let url = URL(fileURLWithPath: "\(cachePath)/\(uuid)/\(pageString)")
//                    try data?.write(to: url)
//                } catch {
//                    print(error)
//                }
//            }
//        }

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

//            try FileManager.default.removeItem(atPath: "\(cachePath)/\(uuid)")

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

//        var width: Float = pdfWidth
//        var height: Float = pdfHeight
//        if angle == 90 || angle == 270 {
//            swapWithoutTuples(&width, &height)
//        }
////        var fittingWidth: Float = 0
//        var dispWidth =  Float(canvasWidth) * scale
//        var dispHeight = Float(canvasHeight) * scale
//
//        if (width / height > dispWidth / dispHeight) {
//            dispHeight = dispWidth * (height / width)
//        } else if (width / height < dispWidth / dispHeight) {
//            dispWidth = dispHeight * (width / height)
//        }
//
//        let posX = (Float(canvasWidth) - dispWidth) / 2
//        let posY = (Float(canvasHeight) - dispHeight) / 2
//
//        if (angle == 90 || angle == 270) {
//            swapWithoutTuples(&width, &height)
//            swapWithoutTuples(&dispWidth, &dispHeight)
//        }
//
//        return(dispWidth, dispHeight, posX, posY)

//        var omniPosX = posX
//        var omniPosY = posY + canvasHeight * ()
    }

}
