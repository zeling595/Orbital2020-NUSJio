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
    
    // filter
    static let faculties = ["FASS", "BIZ", "SoC", "SCALE", "FoD", "SDE", "Duke-NUS", "Engineering", "NGS", "Law", "Medicine", "Music", "Public Health", "Public Policy", "Science", "USP", "Yale-NUS"]
    static let numOfFaculties = faculties.count
    
    // user
    static let defaultProfilePictureURLStr = "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/users%2Fprofile_image_placeholder.jpg?alt=media&token=d2719dc2-97a8-4878-9bb5-facee6d099c9"
    
    // table view cell
    static let cellCornerRadius = 8
}
