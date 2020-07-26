//
//  SelfSizingTableView.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/23.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import UIKit

class SelfSizingTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
      super.reloadData()
      self.invalidateIntrinsicContentSize()
      self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
      let height = max(contentSize.height, maxHeight)
      return CGSize(width: contentSize.width, height: height)
    }
}
