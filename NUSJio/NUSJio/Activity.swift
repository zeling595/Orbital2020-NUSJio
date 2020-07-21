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
    private static var uuidKey = "uuid"
    private static var titleKey = "title"
    private static var descriptionKey = "description"
    private static var hostIdKey = "hostId"
    private static var participantIdsKey = "participantIds"
    private static var participantsInfoKey = "participantsInfo"
    private static var locationKey = "location"
    private static var timeKey = "time"
    // private static var isCompleteKey = "isComplete"
    private static var stateKey = "state"
    private static var imageURLStrKey = "imageURLStr"
    private static var categoriesKey = "categories"
    private static var numOfParticipantsKey = "numOfParticipants"
    private static var genderKey = "gender"
    private static var facultiesKey = "faculties"
    private static var selectedFacultiesBoolArrayKey = "selectedFacultiesBoolArray"
    
    var uuid: String
    var title: String
    var description: String?
    var hostId: String
    var participantIds: [String]
    var participantsInfo: [String: String] // ids and profile pic url
    var location: String?
    var time: Date?
    var state: ActivityState
    // var isComplete: Bool
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
            uuidKey: activity.uuid,
            titleKey: activity.title,
            descriptionKey: activity.description ?? "",
            hostIdKey: activity.hostId,
            participantIdsKey: activity.participantIds,
            participantsInfoKey: activity.participantsInfo,
            locationKey: activity.location ?? "",
            timeKey: activity.time ?? Date.init(),
            stateKey: activity.state.rawValue,
            // isCompleteKey: activity.isComplete,
            imageURLStrKey: activity.imageURLStr,
            categoriesKey: activity.categories ?? NSNull(),
            numOfParticipantsKey: activity.numOfParticipants ?? NSNull(),
            genderKey: activity.gender?.rawValue ?? NSNull(),
            facultiesKey: activity.faculties ?? NSNull(),
            selectedFacultiesBoolArrayKey: activity.selectedFacultiesBoolArray
            ]
    }
    
    // firebase to client
    static func DictionaryToActivity(dictionary: [String: Any]) -> Activity {
        let uuid = dictionary[uuidKey] as! String
        let title = dictionary[titleKey] as! String
        let descripton = dictionary[descriptionKey] as? String ?? ""
        let hostId = dictionary[hostIdKey] as! String
        let participantIds = dictionary[participantIdsKey] as? [String] ?? []
        let participantsInfo = dictionary[participantsInfoKey] as? [String: String] ?? [:]
        let location = dictionary[locationKey] as? String ?? ""
        var time: Date
        if let stamp = dictionary[timeKey] as? Timestamp {
            time = stamp.dateValue()
        } else {
            time = Date.init()
        }
        let stateStr = dictionary[stateKey] as! String
        let state = ActivityState(rawValue: stateStr)!
        // let isComplete = dictionary[isCompleteKey] as! Bool
        let imageURLStr = dictionary[imageURLStrKey] as? String ?? ""
        
        // for tags
        let categories = dictionary[categoriesKey] as? [String] ?? nil
        let numOfParticipants = dictionary[numOfParticipantsKey] as? Int ?? nil
        let genderStr = dictionary[genderKey] as? String ?? nil
        var gender: Gender?
        if let genderStr = genderStr {
            gender = Gender(rawValue: genderStr)
        } else {
            gender = nil
        }
        let faculties = dictionary[facultiesKey] as? [String] ?? nil
        let selectedFacultiesBoolArray = dictionary[selectedFacultiesBoolArrayKey] as? [Bool] ?? Array(repeating: false, count: 17)
        
        return Activity(uuid: uuid, title: title, description: descripton, hostId: hostId, participantIds: participantIds, participantsInfo: participantsInfo, location: location, time: time, state: state, imageURLStr: imageURLStr, categories: categories, numOfParticipants: numOfParticipants, gender: gender, faculties: faculties, selectedFacultiesBoolArray: selectedFacultiesBoolArray)
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
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
}

enum Gender: String, CustomStringConvertible {
       case mixed = "mixed"
       case male = "male"
       case female = "female"
       
       var description: String {
           switch self {
           case .mixed:
               return "Mixed Gender"
           case .male:
               return "Males Only"
           case .female:
               return "Females Only"
       }
    }
}

enum ActivityState: String {
    case open = "open"
    case closed = "closed"
    case completed = "completed"
}

extension Date {
    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = TimeZone.current
            return calender.date(from: dateComponents)
        }
    }
}
