//
//  SlideSizeTableViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class SlideSizeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var delegate: SlideSizeDelegate!
    @IBOutlet weak var collectionView: UICollectionView!
    var configurated = false
    @IBOutlet weak var retinaScaleLabel: UILabel!
    @IBOutlet weak var retinaScaleButton: ModernFluidButton!
    @IBOutlet weak var resetButton: ModernFluidButton!
    var oneXImage: UIImage?
    var twoXImage: UIImage?
    @IBOutlet weak var resetLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        retinaScaleButton.trackedViews = [retinaScaleLabel]
        resetButton.trackedViews = [resetLabel]
    }

    @IBAction func switch1xRetinaTapped(_ sender: Any) {
        delegate.setShouldUseRetina2x(shouldUse: !delegate.getUsingRetina2x())
        if delegate.getUsingRetina2x() {
            if twoXImage == nil {
                twoXImage = UIImage(named: "slideSizeCell_Retina")
            }
            retinaScaleButton.setImage(twoXImage, for: .normal)
            retinaScaleLabel.text = "Retina"
        } else {
            if oneXImage == nil {
                oneXImage = UIImage(named: "slideSizeCell1x")
            }
            retinaScaleButton.setImage(oneXImage, for: .normal)
            retinaScaleLabel.text = "Normal"
        }
    }

    @IBAction func resetToNativeResTapped(_ sender: Any) {
        if let ratioCell = self.collectionView.cellForItem(at: ConfigurationViewController.findIndexPathForResolutionIndex(i: delegate.getNativeSizeIndex(), delegate: delegate)) as? AspectRatioCollectionViewCell {
            ratioCell.selectSizeTapped(ratioCell)
        } else {
            // When the native res bubble is scrolled out of view
            deselectEveryView(ticked: true, native: false)
            delegate.selectSizeAtIndex(index: delegate.getNativeSizeIndex())
        }
    }

    func deselectEveryView(ticked: Bool, native: Bool) {
        for i in 0..<delegate.getAllSizes().count {
            let path = ConfigurationViewController.findIndexPathForResolutionIndex(i: i, delegate: delegate)
            if let toDehighlight = collectionView.cellForItem(at: path) as? AspectRatioCollectionViewCell {
                if ticked {
                    toDehighlight.greenTickView.isHidden = true
                }
                if native {
                    toDehighlight.nativeGoldstarView.isHidden = true
                }
            }
        }
    }

    func configurateCollectionView() {
        if !configurated {
            let layout = JEKScrollableSectionCollectionViewLayout()
            layout.itemSize = CGSize(width: 86, height: 86)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
            layout.minimumInteritemSpacing = 10
            collectionView.collectionViewLayout = layout
            collectionView.delegate = self
            collectionView.dataSource = self
            configurated = true
        }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return delegate.getCutoffCountForScreenResolution()
        } else {
            return delegate.getAllSizes().count - delegate.getCutoffCountForScreenResolution() + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let arrayIndex = indexPath.row + (indexPath.section == 1 ? delegate.getCutoffCountForScreenResolution() : 0)
        if arrayIndex <= delegate.getAllSizes().count - 1  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AspectRatioCollectionViewCell", for: indexPath) as! AspectRatioCollectionViewCell
            let size = delegate.getAllSizes()[arrayIndex]
            cell.correspondingSize = size
            cell.ratioCorrespondingIndex = arrayIndex
            let description = size.description
            if (description.contains("Landscape") || description.contains("Portrait")) {
                var range = (description as NSString).range(of: "Landscape")
                if range.location == NSNotFound {
                    range = (description as NSString).range(of: "Portrait")
                }
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: description)
                attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 9, weight: .regular)], range: range)
                cell.ratioTextLabel.attributedText = attributedString
            } else if (description.contains("W:") && description.contains("H:")) {
                let range1 = (description as NSString).range(of: "W:")
                let range2 = (description as NSString).range(of: "H:")
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: description)
                attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 8, weight: .regular)], range: range1)
                attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 8, weight: .regular)], range: range2)
                attributedString.addAttributes([.kern: 1.55], range: NSRange(location: range2.location, length: 1)) // Assuming SF Text
                let titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.alignment = .left
                attributedString.addAttributes([.paragraphStyle: titleParagraphStyle], range: NSRange(location: 0, length: description.count))
                let monoFont = UIFont.monospacedDigitSystemFont(ofSize: 13.0, weight: .bold)
                attributedString.addAttributes([.font: monoFont], range: NSRange(location: range1.location + range1.length, length: range2.location - (range1.location + range1.length)))
                attributedString.addAttributes([.font: monoFont], range: NSRange(location: range2.location + range2.length, length: description.count - (range2.location + range2.length)))
                cell.ratioTextLabel.attributedText = attributedString
            } else {
                cell.ratioTextLabel.text = size.description
            }
            cell.delegate = self.delegate
            cell.parentTableCell = self
            cell.configurateCellAppearance()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomEntryCollectionViewCell", for: indexPath) as! CustomEntryCollectionViewCell
            cell.delegate = self.delegate
            cell.parentTableViewCell = self
            return cell
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
