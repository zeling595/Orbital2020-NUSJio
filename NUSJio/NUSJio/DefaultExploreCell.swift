//
//  DefaultExploreCell.swift
//  
//
//  Created by 程及雨晴 on 29/6/20.
//

import UIKit

class DefaultExploreCell: UITableViewCell {

    @IBOutlet var activityImage: UIImageView!
    @IBOutlet var activityDescription: UILabel!
    @IBOutlet var activityTitle: UILabel!
    //override func awakeFromNib() {
      //  super.awakeFromNib()
        // Initialization code
    //}

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
