//
//  Activity.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import UIKit

struct Activity {
    var title: String
    var description: String?
    var host: User? // shouldnt be optional, will fix later
    var participants: [User]?
    var location: String? // shouldnt be optional, will fix later
    var time: Date
    var tags: [String]?
    var isComplete: Bool
    var coverPicture: UIImage?
    
    static let timeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // for creating new activity
//    init(title title: String, description description: String?, host host: User?, location location: String?, time time: Date, coverPicture coverPicture: UIImage) {
//        self.title = title
//        self.description = description
//        self.host = host
//        self.participants = nil
//        self.location = location
//        self.time = time
//        self.tags = nil
//        self.isComplete = false
//        self.coverPicture = coverPicture
//    }
    
    static func loadActivities() -> [Activity]? {
        // retrieve the array of items stored on disk and returns them if the disk contains any items
        return nil
    }
    
    static func loadSampleActivities() -> [Activity] {
        let activity1 = Activity(title: "Dinner @The Deck", description: nil, host: User(username: "Cherry"), participants: nil, location: "The Deck", time: Date(), tags: nil, isComplete: false, coverPicture: nil)
        
        let activity2 = Activity(title: "Swimming @Utown", description: nil, host: User(username: "Sherry"), participants: nil, location: "Utown", time: Date(), tags: nil, isComplete: false, coverPicture: nil)
        
        let activity3 = Activity(title: "Jogging @Track", description: nil, host: User(username: "Henry"), participants: nil, location: "Track", time: Date(), tags: nil, isComplete: false, coverPicture: nil)
        
        return [activity1, activity2, activity3]
    }
    
}
