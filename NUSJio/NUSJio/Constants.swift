//
//  Constants.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/4.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        // view controllers
        static let customTabBarController = "CustomTabBarController"
        static let addActivityTableViewController = "AddActivityTableViewController"
        static let editActivityTableViewController = "EditActivityTableViewController"
        
        static let locationSearchTableViewController = "LocationSearchTableViewController"
        
        // cell identifiers
        static let activityCellIdentifier = "ActivityCellIdentifier"
        static let searchResultCellIdentifier = "SearchResultCellIdentifier"
        
        // segue
        static let editActivitySegue = "EditActivitySegue"
        static let viewActivityDetailSegue = "ViewActivityDetailSegue"
        static let saveUnwindToMyActivities = "SaveUnwindToMyActivities"
        static let saveUnwindToActivityDetail = "SaveUnwindToActivityDetail"
        static let saveUnwindToAddActivity = "SaveUnwindToAddActivity"
        static let saveToActivityDetail = "SaveToActivityDetail"
    }
}
