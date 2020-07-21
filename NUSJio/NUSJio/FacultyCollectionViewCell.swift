//
//  FacultyCollectionViewCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/3.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class FacultyCollectionViewCell: UICollectionViewCell {
    @IBOutlet var facultyLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                facultyLabel.backgroundColor = Styles.themeOrange
            } else {
                facultyLabel.backgroundColor = Styles.themeBlue
            }
        }
    }
}
