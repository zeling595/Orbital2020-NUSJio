//
//  ParticipantCollectionViewCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/12.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class ParticipantCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var participantImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        participantImageView.layer.cornerRadius = participantImageView.frame.height / 2
//        participantImageView.layer.masksToBounds = true
    }
}
