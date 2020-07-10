//
//  DynamicHeightCollectionView.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/9.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
//    override func reloadData() {
//        super.reloadData()
//        self.invalidateIntrinsicContentSize()
//    }
    
    override var intrinsicContentSize: CGSize {
       // print(self.collectionViewLayout.collectionViewContentSize)
        return self.collectionViewLayout.collectionViewContentSize
    }

}
