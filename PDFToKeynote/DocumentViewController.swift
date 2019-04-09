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

class DocumentViewController: UIViewController, FloatingPanelControllerDelegate {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var natigationBarItem: UINavigationItem!
    @IBOutlet weak var navigationDoneButton: UIBarButtonItem!
    var document: UIDocument?
    var floatingController: FloatingPanelController?
    weak var configurationVC: ConfigurationViewController?

    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        print("Size class: (V: \(newCollection.verticalSizeClass.rawValue), H: \(newCollection.horizontalSizeClass.rawValue))")
        if newCollection.verticalSizeClass == .regular && newCollection.horizontalSizeClass == .regular {
            print("Returning ConverterFloatingLandscapePanelLayout")
            return ConverterFloatingLandscapePanelLayout()
        } else {
            print("Returning ConverterFloatingPanelLayout")
            return ConverterFloatingPanelLayout()
        }
//        return (newCollection.verticalSizeClass == .regular) ? ConverterFloatingPanelLayout() : ConverterFloatingLandscapePanelLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

//        if (traitCollection.horizontalSizeClass == .compact) {
//        } else {
//            floatingController?.removePanelFromParent(animated: false)
//        }
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
                self.floatingController?.move(to: .tip, animated: true)
            }
            floatingController?.addPanel(toParent: self)
            //            floatingController?.move(to: .full, animated: true)
            floatingController?.track(scrollView: configurationVC!.tableView)
        }

        document?.open(completionHandler: { (success) in
            if success {
                self.natigationBarItem.title = self.document?.fileURL.lastPathComponent.stripFileExtension()
                self.pdfView.document = PDFDocument(url: self.document!.fileURL)
                self.pdfView.backgroundColor = UIColor.gray
                self.pdfView.autoScales = true
                self.configurationVC?.pdf = self.pdfView.document
                if let doc = self.document as? Document {
                    self.configurationVC?.initialSetupForPDF(doc)
                }
            } else {
                print("Failed to load PDF document")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
