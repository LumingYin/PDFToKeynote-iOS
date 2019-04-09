//
//  BackgroundColorViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class BackgroundColorViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 6
        } else {
            return 1
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleColorCollectionViewCell", for: indexPath)
            return cell
        } else if (indexPath.section == 1) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleColorCollectionViewCell", for: indexPath)
            if (indexPath.row == 5) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomAspectRatioCollectionViewCell", for: indexPath)
                return cell
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomAspectRatioCollectionViewCell", for: indexPath)
            return cell
        }
    }

    var isConfigured = false
    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configurateCollectionView() {
        if !isConfigured {
//            (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = CGFloat.greatestFiniteMagnitude
//            let flowLayout = UICollectionViewFlowLayout()
//            flowLayout.itemSize = CGSize(width: 86, height: 86)
//            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
//            flowLayout.minimumInteritemSpacing = 0.0
//            self.collectionView.collectionViewLayout = flowLayout
//            collectionView.collectionViewLayout = MultpleLineLayout()
            collectionView.delegate = self
            collectionView.dataSource = self
            isConfigured = true
            collectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
