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

class DocumentViewController: UIViewController, FloatingPanelControllerDelegate {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var natigationBarItem: UINavigationItem!
    @IBOutlet weak var navigationDoneButton: UIBarButtonItem!
    var document: UIDocument?
    var floatingController: FloatingPanelController?
    weak var configurationVC: ConfigurationViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        var urlpath = Bundle.main.path(forResource: "test", ofType: "pdf")!
        document = Document(fileURL: URL(fileURLWithPath: urlpath))
    }

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
//        print("Size class: (V: \(newCollection.verticalSizeClass.rawValue), H: \(newCollection.horizontalSizeClass.rawValue))")
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad // Workaround for layout constraint bugs by fixating width to always be 320
        if (newCollection.verticalSizeClass == .regular && newCollection.horizontalSizeClass == .regular) {
            return ConverterFloatingLandscapePanelLayout()
        } else if (isiPad) {
            return ConverterFloatingiPadNonLandscapePanelLayout()
        } else {
            return ConverterFloatingPanelLayout()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    }

    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        if vc.position == .full {
            configurationVC?.customizeLabel.text = "Minimize"
        } else {
            configurationVC?.customizeLabel.text = "Customize"
            configurationVC?.tableView.scrollToRow(at: IndexPath(row: 0, column: 0), at: .top, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if floatingController == nil {
            floatingController = FloatingPanelController()
            floatingController?.surfaceView.backgroundColor = .clear
            floatingController?.surfaceView.cornerRadiusFP = 9.0
            floatingController?.surfaceView.shadowHidden = false
            floatingController?.delegate = self

            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            configurationVC = storyBoard.instantiateViewController(withIdentifier: "ConfigurationViewController") as? ConfigurationViewController
            configurationVC?.enableDisableStateChanged = { state in
                self.navigationDoneButton.isEnabled = state
            }
            floatingController?.set(contentViewController: configurationVC)
            configurationVC?.moveToPosition = {
                if self.floatingController?.position != .full {
                    self.floatingController?.move(to: .full, animated: true)
                } else {
                    self.floatingController?.move(to: .tip, animated: true)
                }
            }
            configurationVC?.hideToTip = {
                if self.floatingController?.position != .tip {
                    self.floatingController?.move(to: .tip, animated: true)
                } else {
                    self.dismissDocumentViewController()
                }
            }
            floatingController?.addPanel(toParent: self)
            floatingController?.track(scrollView: configurationVC!.tableView)
        }

        document?.open(completionHandler: { (success) in
            if success {
                self.natigationBarItem.title = self.document?.fileURL.lastPathComponent.stripFileExtension()
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
                self.pdfView.backgroundColor = UIColor.gray
                self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit
                self.scrollToTop()
//                self.pdfView.autoScales = true
                self.configurationVC?.pdf = self.pdfView.document
                if let doc = self.document as? Document {
                    self.configurationVC?.initialSetupForPDF(doc)
                }
            } else {
                print("Failed to load PDF document")
            }
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            if self.pdfView.scaleFactor > self.pdfView.scaleFactorForSizeToFit {
                self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit
            }
        }
    }
    
    func scrollToTop() {
        var topLeftX: CGFloat!
        var topLeftY: CGFloat!
        guard let firstPage = pdfView!.document?.page(at: 0) else {
            return;
        }
        let firstPageBounds = firstPage.bounds(for: pdfView!.displayBox)
        switch (firstPage.rotation % 360) {
        case 0:
            topLeftX = firstPageBounds.minX
            topLeftY = firstPageBounds.maxY
        case 90:
            topLeftX = firstPageBounds.minX
            topLeftY = firstPageBounds.minY
        case 180:
            topLeftX = firstPageBounds.maxX
            topLeftY = firstPageBounds.minY
        case 270:
            topLeftX = firstPageBounds.maxX
            topLeftY = firstPageBounds.maxY
        default:
            print ("Invalid rotation value, not divisible by 90")
        }
        
        pdfView!.go(to: CGRect(x: topLeftX, y: topLeftY, width: 1.0, height: 1.0), on: firstPage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismissDocumentViewController() {
        SVProgressHUD.dismiss()
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension UIVisualEffectView {

}

