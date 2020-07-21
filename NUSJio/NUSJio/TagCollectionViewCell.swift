//
//  TagCollectionViewCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/4.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.backgroundColor = Styles.themeBlue
        tagLabel.textColor = UIColor.white
    }
}
