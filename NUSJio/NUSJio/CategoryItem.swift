//
//  CategoryItem.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/1.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation

class CategoryItem {
    var isSelected = false
    var categoryTitle: String
    
    init(_ categoryTitle: String) {
        self.categoryTitle = categoryTitle
    }
    
    static func loadListOfCategories() -> [CategoryItem] {
        return [
            CategoryItem("Food"),
            CategoryItem("Movie"),
            CategoryItem("Study"),
            CategoryItem("Exercise"),
            CategoryItem("Shopping"),
            CategoryItem("Language"),
            CategoryItem("Project")
        ]
    }
}
