//
//  CustomEntryCollectionViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class CustomEntryCollectionViewCell: UICollectionViewCell, UIPopoverPresentationControllerDelegate {
    weak var delegate: SlideSizeDelegate!
    weak var parentTableViewCell: SlideSizeTableViewCell!

    @IBAction func addCustomEntryTapped(_ sender: UIButton) {
        self.addNewAspectRatioTapped(sender)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func addNewAspectRatioTapped(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "AddWidthHeight") as! AddWidthHeightViewController
        controller.newSizeAdded = { (width, height) in
//            self.delegate.addNewSize(width: width, height: height, description: "\(width) × \(height)")
            self.delegate.addNewSize(width: width, height: height, description: "\(width)\n\(height)")
            let sectionOneLocation = self.delegate.getAllSizes().count - self.delegate.getCutoffCountForScreenResolution() - 1
            self.delegate.selectSizeAtIndex(index: self.delegate.getAllSizes().count - 1)
            let newIndexPath = IndexPath(row: sectionOneLocation, section: 1)
            self.parentTableViewCell.collectionView.insertItems(at: [newIndexPath])
            self.parentTableViewCell.collectionView.reloadItems(at: [newIndexPath])
            self.parentTableViewCell.collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
            if let newItem = self.parentTableViewCell.collectionView.cellForItem(at: newIndexPath) as? AspectRatioCollectionViewCell {
                newItem.selectSizeTapped(newItem)
            }
//            self.sizes.append((width, height, "Custom: \(width) × \(height)"))
//            self.dimensionPicker.reloadComponent(0)
//            self.dimensionPicker.selectRow(self.sizes.count - 1, inComponent: 0, animated: true)
//            self.aspectRatioLabel.text = self.sizes[self.selectedRow].description
        }
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 300, height: 200)
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.backgroundColor = controller.view.backgroundColor
        presentationController.delegate = self
        presentationController.sourceView = sender
        presentationController.sourceRect = sender.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        if let conf = self.delegate as? ConfigurationViewController {
            conf.present(controller, animated: true)
        }
    }

}
