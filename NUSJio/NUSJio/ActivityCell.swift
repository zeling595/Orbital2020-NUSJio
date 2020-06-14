//
//  ActivityCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/13.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var participantsLabel: UILabel!
    @IBOutlet var countdownLabel: UILabel!
    @IBOutlet var postponeButoon: UIButton!
    @IBOutlet var startButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
