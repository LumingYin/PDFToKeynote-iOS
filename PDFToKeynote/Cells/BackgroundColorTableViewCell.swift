//
//  BackgroundColorTableViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class BackgroundColorTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    var isConfigured = false
    @IBOutlet weak var colorHexCodeLabel: UILabel!
    @IBOutlet weak var colorReadableDescriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: ColorPickerDelegate?
    
    var greyscaleColors: [UIColor] = [UIColor(hexString: "FFFFFE"),
                                      UIColor(hexString: "000000"),
                                      UIColor(hexString: "929192"),
                                      UIColor(hexString: "5D5D5D"),
                                      UIColor(hexString: "D5D4D4")]
    var rainbowColors: [[UIColor]] = [[UIColor(hexString: "73BDF9"),
                                       UIColor(hexString: "489EF7"),
                                       UIColor(hexString: "3274B4"),
                                       UIColor(hexString: "1E4B7B")],

                                      [UIColor(hexString: "99F9EB"),
                                       UIColor(hexString: "6BE3CF"),
                                       UIColor(hexString: "4BA59D"),
                                       UIColor(hexString: "347975")],

                                      [UIColor(hexString: "A4F669"),
                                       UIColor(hexString: "81D552"),
                                       UIColor(hexString: "54AE32"),
                                       UIColor(hexString: "2F6F1C")],

                                      [UIColor(hexString: "FEFB7E"),
                                       UIColor(hexString: "F5E359"),
                                       UIColor(hexString: "EEBE41"),
                                       UIColor(hexString: "EF9936")],

                                      [UIColor(hexString: "F09B90"),
                                       UIColor(hexString: "EB6E57"),
                                       UIColor(hexString: "EB6E57"),
                                       UIColor(hexString: "A62B19")],

                                      [UIColor(hexString: "EF92C3"),
                                       UIColor(hexString: "DD68A5"),
                                       UIColor(hexString: "BA3979"),
                                       UIColor(hexString: "8D275D")],
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configurateCollectionView() {
        if !isConfigured {
            let layout = JEKScrollableSectionCollectionViewLayout()
            layout.itemSize = CGSize(width: 86, height: 86)
            layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            layout.minimumInteritemSpacing = 0
            collectionView.collectionViewLayout = layout
            collectionView.delegate = self
            collectionView.dataSource = self
            isConfigured = true
            collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return greyscaleColors.count + 1
        } else if section == 1 {
            return rainbowColors.count + 1
        } else {
            return 0
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && indexPath.row < greyscaleColors.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleColorCollectionViewCell", for: indexPath) as! SingleColorCollectionViewCell
            cell.delegate = self.delegate
            cell.colorView.backgroundColor = greyscaleColors[indexPath.row]
            cell.colorTappedCallback = { Int, cell in
                cell.greenTickView.isHidden = false
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row < rainbowColors.count  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleColorCollectionViewCell", for: indexPath) as! MultipleColorCollectionViewCell
            cell.delegate = self.delegate
            let rainbow = rainbowColors[indexPath.row]
            cell.color1Button.backgroundColor = rainbow[0]
            cell.color2Button.backgroundColor = rainbow[1]
            cell.color3Button.backgroundColor = rainbow[2]
            cell.color4Button.backgroundColor = rainbow[3]
            cell.colorTappedCallback = { index, cell in
                cell.greenTickView.isHidden = false
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomEntryCollectionViewCell", for: indexPath)
            return cell
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
