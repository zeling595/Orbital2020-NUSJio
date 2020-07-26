//
//  MeTableViewCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/23.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class MeTableViewCell: UITableViewCell {

    @IBOutlet var mainView: UIView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var indicatorButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
