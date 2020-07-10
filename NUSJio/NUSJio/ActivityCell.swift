//
//  ActivityCell.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/13.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

protocol ActivityCellDelegate: class {
    func startButtonTapped(sender: ActivityCell)
}

class ActivityCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    weak var delegate: ActivityCellDelegate?
    var tags: [String] = []

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var tagsCollectionView: UICollectionView!
    @IBOutlet var countdownLabel: UILabel!
    @IBOutlet var postponeButoon: UIButton!
    @IBOutlet var startButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        // align to the left
        let alignedFlowLayout = tagsCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.minimumLineSpacing = 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = tags[indexPath.item]
        return cell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func startButtonTapped() {
        delegate?.startButtonTapped(sender: self)
    }
}


