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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func switch1xRetinaTapped(_ sender: Any) {
        delegate.setShouldUseRetina2x(shouldUse: delegate.getUsingRetina2x())
    }

    @IBAction func resetToNativeResTapped(_ sender: Any) {
        delegate.selectSizeAtIndex(index: delegate.getNativeSizeIndex())
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
            return delegate.getAllSizes().count
        } else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AspectRatioCollectionViewCell", for: indexPath) as! AspectRatioCollectionViewCell
            let size = delegate.getAllSizes()[indexPath.row]
            cell.ratioTextLabel.text = size.description
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomEntryCollectionViewCell", for: indexPath)
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
