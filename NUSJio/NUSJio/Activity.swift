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
    static let uuidKey = "uuid"
    static let titleKey = "title"
    static let descriptionKey = "description"
    static let hostIdKey = "hostId"
    static let participantIdsKey = "participantIds"
    static let participantsInfoKey = "participantsInfo"
    static let likedByKey = "likedBy"
    static let locationKey = "location"
    static let timeKey = "time"
    static let stateKey = "state"
    static let imageURLStrKey = "imageURLStr"
    static let categoriesKey = "categories"
    static let numOfParticipantsKey = "numOfParticipants"
    static let genderKey = "gender"
    static let facultiesKey = "faculties"
    static let selectedFacultiesBoolArrayKey = "selectedFacultiesBoolArray"
    
    var uuid: String
    var title: String
    var description: String?
    var hostId: String
    var participantIds: [String]
    var participantsInfo: [String: String] // ids and profile pic url
    var likedBy: [String]
    var location: String?
    var time: Date?
    var state: ActivityState
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
            likedByKey: activity.likedBy,
            locationKey: activity.location ?? "",
            timeKey: activity.time ?? Date.init(),
            stateKey: activity.state.rawValue,
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
        let likedBy = dictionary[likedByKey] as? [String] ?? []
        let location = dictionary[locationKey] as? String ?? ""
        var time: Date
        if let stamp = dictionary[timeKey] as? Timestamp {
            time = stamp.dateValue()
        } else {
            time = Date.init()
        }
        let stateStr = dictionary[stateKey] as! String
        let state = ActivityState(rawValue: stateStr)!
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
        
        return Activity(uuid: uuid, title: title, description: descripton, hostId: hostId, participantIds: participantIds, participantsInfo: participantsInfo, likedBy: likedBy, location: location, time: time, state: state, imageURLStr: imageURLStr, categories: categories, numOfParticipants: numOfParticipants, gender: gender, faculties: faculties, selectedFacultiesBoolArray: selectedFacultiesBoolArray)
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
