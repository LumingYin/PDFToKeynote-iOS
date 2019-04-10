//
//  CustomEntryCollectionViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

enum CustomEntryMode {
    case color
    case size
}

class CustomEntryCollectionViewCell: UICollectionViewCell, UIPopoverPresentationControllerDelegate, ChromaColorPickerDelegate {
    weak var delegate: SlideSizeDelegate!
    weak var parentTableViewCell: SlideSizeTableViewCell!
    var isColorMode = false
    var colorSelectionCallback: ((UIColor) -> Void)?
    weak var colorDelegate: ColorPickerDelegate!

    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    @IBOutlet weak var addEntryButton: ModernFluidButton!

    override func awakeFromNib() {
        addEntryButton.trackedViews = [customLabel, visualEffectsView]
    }

    @IBAction func addCustomEntryTapped(_ sender: UIButton) {
        if !isColorMode {
            self.addNewAspectRatioTapped(sender)
        } else {
            var neatColorPicker: ChromaColorPicker!

            neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
            neatColorPicker.supportsShadesOfGray = true
            neatColorPicker.togglePickerColorMode()
//            neatColorPicker.adjustToColor(selectedColor)
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
            if let presenter = self.colorDelegate as? ConfigurationViewController {
                presenter.present(controller, animated: true)
            }

        }
    }

    @objc func colorChanged(_ colorPicker: ChromaColorPicker) {
//        colorSelectionCallback?(colorPicker.currentColor)
//        selectedColor = colorPicker.currentColor
    }

    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        colorSelectionCallback?(color)
    }


    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func addNewAspectRatioTapped(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "AddWidthHeight") as! AddWidthHeightViewController
        controller.newSizeAdded = { (width, height) in
//            self.delegate.addNewSize(width: width, height: height, description: "\(width) × \(height)")
            self.delegate.addNewSize(width: width, height: height, description: "W:\(width)\nH:\(height)")
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
