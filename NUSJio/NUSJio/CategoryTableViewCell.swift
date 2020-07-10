//
//  CategoryTableViewCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/1.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet var categoryLabel: UILabel!
    var item: CategoryItem? {
        didSet {
            categoryLabel.text = item?.categoryTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        accessoryType = selected ? .checkmark : .none
    }

}
