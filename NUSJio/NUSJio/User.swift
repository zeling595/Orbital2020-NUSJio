//
//  User.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import Firebase

struct User {
    static let uuidKey = "uuid"
    static let usernameKey = "username"
    static let emailKey = "email"
    static let passwordKey = "password"
    static let profilePictureURLStrKey = "profilePictureURLStr"
    static let myActivityIdsKey = "myActivityIds"
    static let joinedActivityIdsKey = "joinedActivityIds"
    static let likedActivityIdsKey = "likedActivityIds"
    static let scheduleKey = "schedule"
    
    var uuid: String
    var username: String
    var email: String
    var password: String
    var profilePictureURLStr: String?
    var myActivityIds: [String]?
    var joinedActivityIds: [String]?
    var likedActivityIds: [String]?
    var schedule: [Date]?
    
    static func UserToDictionary(user: User) -> [String: Any] {
        return [
            uuidKey: user.uuid,
            usernameKey: user.username,
            emailKey: user.email,
            passwordKey: user.password,
            profilePictureURLStrKey: user.profilePictureURLStr ?? Constants.defaultProfilePictureURLStr,
            myActivityIdsKey: user.myActivityIds ?? [],
            joinedActivityIdsKey: user.joinedActivityIds ?? [],
            likedActivityIdsKey: user.likedActivityIds ?? [],
            scheduleKey: user.schedule ?? []
        ]
    }
    
    static func DictionaryToUser(dictionary: [String: Any]) -> User {
        let uuid = dictionary[uuidKey] as! String
        let username = dictionary[usernameKey] as! String
        let email = dictionary[emailKey] as! String
        let password = dictionary[passwordKey] as! String
        let profilePictureURLStr = dictionary[profilePictureURLStrKey] as? String ?? Constants.defaultProfilePictureURLStr
        let myActivityIds = dictionary[myActivityIdsKey] as? [String]? ?? []
        let joinedActivityIds = dictionary[joinedActivityIdsKey] as? [String]? ?? []
        let likedActivityIds = dictionary[likedActivityIdsKey] as? [String]? ?? []
        var schedule: [Date]
        if let stamp = dictionary[scheduleKey] as? [Timestamp] {
            schedule = stamp.map({ (timestamp) -> Date in
                timestamp.dateValue()
            })
        } else {
            schedule = []
        }
        
        return User(uuid: uuid, username: username, email: email, password: password, profilePictureURLStr: profilePictureURLStr, myActivityIds: myActivityIds, joinedActivityIds: joinedActivityIds, likedActivityIds: likedActivityIds, schedule: schedule)
    }
}
