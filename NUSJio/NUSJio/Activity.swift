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
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    static func loadActivities() -> [Activity]? {
        // retrieve the array of items stored on disk and returns them if the disk contains any items
        return nil
    }
    
    static func loadSampleActivities() -> [Activity] {
        let activity1 = Activity(
            title: "Dinner @The Deck",
            description: nil,
            host: User(username: "Cherry"),
            participants: nil,
            location: "The Deck",
            time: timeDateFormatter.date(from: "2020/10/08 22:31")!,
            tags: nil,
            isComplete: false,
            coverPicture: UIImage(named: "The-Deck")
        )
        
        let activity2 = Activity(
            title: "Swimming @Utown",
            description: nil,
            host: User(username: "Sherry"),
            participants: nil,
            location: "Utown",
            time: timeDateFormatter.date(from: "2020/11/11 11:11")!,
            tags: nil,
            isComplete: false,
            coverPicture: nil //UIImage(named: "Fine-Food")
        )
        
        let activity3 = Activity(
            title: "Jogging @Track",
            description: nil,
            host: User(username: "Henry"),
            participants: nil,
            location: "Track",
            time: timeDateFormatter.date(from: "2020/07/31 03:00")!,
            tags: nil,
            isComplete: false,
            coverPicture: nil //UIImage(named: "Outdoor-Pool")
        )
        
        return [activity1, activity2, activity3]
    }
    
}
