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
    var isComplete: Bool
    var imageURLStr: String
    
    // tags
    var categories: [String]?
    var numOfParticipants: Int?
    var gender: Gender?
    var faculties: [String]?
    var selectedFacultiesBoolArray: [Bool] = Array(repeating: false, count: 17)
    
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
            "isComplete": activity.isComplete,
            "imageURLStr": activity.imageURLStr,
            "categories": activity.categories ?? nil,
            "numOfParticipants": activity.numOfParticipants ?? nil,
            "gender": activity.gender ?? nil,
            "faculties": activity.faculties ?? nil,
            "selectedFacultiesBoolArray": activity.selectedFacultiesBoolArray
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
        let isComplete = dictionary["isComplete"] as! Bool
        let imageURLStr = dictionary["imageURLStr"] as? String ?? ""
        
        // for tags
        let categories = dictionary["categories"] as? [String] ?? nil
        let numOfParticipants = dictionary["numOfParticipants"] as? Int ?? nil
        let gender = dictionary["gender"] as? Gender ?? nil
        let faculties = dictionary["faculties"] as? [String] ?? nil
        let selectedFacultiesBoolArray = dictionary["selectedFacultiesBoolArray"] as? [Bool] ?? Array(repeating: false, count: 17)
        
        return Activity(uuid: uuid, title: title, description: descripton, hostId: hostId, participantIds: participantIds, location: location, time: time, isComplete: isComplete, imageURLStr: imageURLStr, categories: categories, numOfParticipants: numOfParticipants, gender: gender, faculties: faculties, selectedFacultiesBoolArray: selectedFacultiesBoolArray)
    }
    
    static func getTagsArray(activity: Activity) -> [String] {
        var tags: [String] = []
        if let categories = activity.categories {
            tags.append(contentsOf: categories)
        }
        if let gender = activity.gender {
            tags.append(gender.description)
        }
        if let faculties = activity.faculties {
            tags.append(contentsOf: faculties)
        }
        if let numOfParticipants = activity.numOfParticipants {
            tags.append("\(numOfParticipants) participants")
        }
        return tags
    }
    
    static func getFilter(activity: Activity) -> Filter? {
        return Filter(categories: activity.categories, numOfParticipants: activity.numOfParticipants, gender: activity.gender, faculties: activity.faculties, selectedFacultiesBoolArray: activity.selectedFacultiesBoolArray)
    }
   
    static let timeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
//    static func loadSampleActivities() -> [Activity] {
//        let activity1 = Activity(
//            uuid: "1",
//            title: "Dinner @The Deck",
//            description: nil,
//            hostId: "1",
//            participantIds: nil,
//            location: "The Deck",
//            time: timeDateFormatter.date(from: "2020/10/08 22:31")!,
//            tags: nil,
//            isComplete: false,
//            imageURLStr: "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/activities%2FThe-Deck.jpg?alt=media&token=c14b106b-4fcb-469c-ba94-19a945d74599"
//        )
//
//        let activity2 = Activity(
//            uuid: "2",
//            title: "Swimming @Utown",
//            description: nil,
//            hostId: "2",
//            participantIds: nil,
//            location: "Utown",
//            time: timeDateFormatter.date(from: "2020/11/11 11:11")!,
//            tags: nil,
//            isComplete: false,
//            imageURLStr: "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/activities%2FFine-Food.jpg?alt=media&token=4415534e-e256-4868-aa2d-644ca9037851"
//        )
//
//        let activity3 = Activity(
//            uuid: "3",
//            title: "Jogging @Track",
//            description: nil,
//            hostId: "3",
//            participantIds: nil,
//            location: "Track",
//            time: timeDateFormatter.date(from: "2020/07/31 03:00")!,
//            tags: nil,
//            isComplete: false,
//            imageURLStr: "https://firebasestorage.googleapis.com/v0/b/nusjio.appspot.com/o/activities%2FOutdoor-Pool.jpg?alt=media&token=902a0e9f-1f1c-4a35-9b8b-431af4df3d67"
//        )
//
//        return [activity1, activity2, activity3]
//    }
    
}
