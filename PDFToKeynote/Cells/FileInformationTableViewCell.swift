//
//  FileInformationTableViewCell.swift
//  PDFToKeynote
//
//  Created by Blue on 4/9/19.
//  Copyright © 2019 Blue. All rights reserved.
//

import UIKit

class FileInformationTableViewCell: UITableViewCell {
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var documentResolutionLabel: UILabel!
    @IBOutlet weak var documentSizeLabel: UILabel!
    @IBOutlet weak var documentPageCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
