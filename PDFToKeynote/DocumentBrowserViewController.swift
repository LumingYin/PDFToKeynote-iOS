//
//  DocumentBrowserViewController.swift
//  PDFToKeynote
//
//  Created by Blue on 4/7/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    var creditsVC: AcknowledgementsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        allowsDocumentCreation = false
        delegate = self
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        browserUserInterfaceStyle = .dark
        view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
        let creditsBarButtonItem = UIBarButtonItem(image: UIImage(named: "info"), style: .done, target: self, action: #selector(showCredits))
        self.additionalTrailingNavigationBarButtonItems = [creditsBarButtonItem]
    }

    @objc func showCredits() {
        creditsVC = AcknowledgementsTableViewController()
        creditsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissCredits))
        let navCon = UINavigationController(rootViewController: creditsVC)
        navCon.modalPresentationStyle = .formSheet
        self.present(navCon, animated: true, completion: nil)
    }

    @objc func dismissCredits() {
        creditsVC.dismiss(animated: true, completion: nil)
    }

    // MARK: UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        documentViewController.document = Document(fileURL: documentURL)
        
        present(documentViewController, animated: true, completion: nil)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

