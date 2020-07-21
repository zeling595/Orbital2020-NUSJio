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
    func jioButtonTapped(cell: ActivityCell)
    func completeButtonTapped(cell: ActivityCell)
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
    @IBOutlet var mainView: UIView!
    @IBOutlet var buttonStackView: UIStackView!
    
    var postponeButton: UIButton?
    var jioButton: UIButton?
    var viewButton: UIButton?
    var completeButton: UIButton?
    
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
    
    @objc @IBAction func jioButtonTapped(sender: UIButton) {
        self.delegate?.jioButtonTapped(cell: self)
    }
    
    @objc @IBAction func completeButtonTapped(sender: UIButton) {
        self.delegate?.completeButtonTapped(cell: self)
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
}


