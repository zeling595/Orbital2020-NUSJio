//
//  Activity.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct Activity {
    var uuid: String
    var title: String
    var description: String?
    var hostId: String
    var participantIds: [String]?
    var location: String?
    var time: Date?
    var tags: [String]?
    var isComplete: Bool
    // var coverPicture: UIImage?
    var imageURLStr: String
    
    // client to firebase
    static func activityToDictionary(activity: Activity) -> [String: Any] {
        return [
            "uuid": activity.uuid,
            "title": activity.title,
            "description": activity.description ?? "",
            "hostId": activity.hostId,
            "participantIds": activity.participantIds ?? [],
            "location": activity.location ?? "",
            "time": activity.time ?? Date.init(),
            "tags": activity.tags ?? [],
            "isComplete": activity.isComplete,
            "imageURLStr": activity.imageURLStr
            ]
    }
    
    // firebase to client
    static func DictionaryToActivity(dictionary: [String: Any]) -> Activity {
        let uuid = dictionary["uuid"] as! String
        let title = dictionary["title"] as! String
        let descripton = dictionary["description"] as? String ?? ""
        let hostId = dictionary["hostId"] as! String
        let participantIds = dictionary["participantIds"] as? [String] ?? []
        let location = dictionary["location"] as? String ?? ""
        var time: Date
        if let stamp = dictionary["time"] as? Timestamp {
            time = stamp.dateValue()
        } else {
            time = Date.init()
        }
        let tags = dictionary["tags"] as? [String] ?? []
        let isComplete = dictionary["isComplete"] as! Bool
        let imageURLStr = dictionary["imageURLStr"] as? String ?? ""
        
        return Activity(uuid: uuid, title: title, description: descripton, hostId: hostId, participantIds: participantIds, location: location, time: time, tags: tags, isComplete: isComplete, imageURLStr: imageURLStr)
    }
   
    static let timeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    static func loadActivities() -> [Activity]? {
        // retrieve the array of items stored on disk and returns them if the disk contains any items
//        guard let codedActivities = try? Data(contentsOf: ArchiveURL) else {return nil}
//
//        let propertyListDecoder = PropertyListDecoder()
//        return try? propertyListDecoder.decode(Array<Activity>.self, from: codedActivities)
        return nil
    }
    
//    static func saveActivities(_ activities: [Activity]) {
//        let propertyListEncoder = PropertyListEncoder()
//        let codedActivities = try? propertyListEncoder.encode(activities)
//        try? codedActivities?.write(to: ArchiveURL, options: .noFileProtection)
//    }
    
    static func loadSampleActivities() -> [Activity] {
        let activity1 = Activity(
            uuid: "1",
            title: "Dinner @The Deck",
            description: nil,
            hostId: "1",
            participantIds: nil,
            location: "The Deck",
            time: timeDateFormatter.date(from: "2020/10/08 22:31")!,
            tags: nil,
            isComplete: false,
            imageURLStr: "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/activities%2FThe-Deck.jpg?alt=media&token=c14b106b-4fcb-469c-ba94-19a945d74599"
        )
        
        let activity2 = Activity(
            uuid: "2",
            title: "Swimming @Utown",
            description: nil,
            hostId: "2",
            participantIds: nil,
            location: "Utown",
            time: timeDateFormatter.date(from: "2020/11/11 11:11")!,
            tags: nil,
            isComplete: false,
            imageURLStr: "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/activities%2FFine-Food.jpg?alt=media&token=4415534e-e256-4868-aa2d-644ca9037851"
        )
        
        let activity3 = Activity(
            uuid: "3",
            title: "Jogging @Track",
            description: nil,
            hostId: "3",
            participantIds: nil,
            location: "Track",
            time: timeDateFormatter.date(from: "2020/07/31 03:00")!,
            tags: nil,
            isComplete: false,
            imageURLStr: "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/activities%2FOutdoor-Pool.jpg?alt=media&token=902a0e9f-1f1c-4a35-9b8b-431af4df3d67"
        )
        
        return [activity1, activity2, activity3]
    }
    
}
