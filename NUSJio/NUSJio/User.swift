//
//  User.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation

struct User {
    var uuid: String
    var username: String
    var email: String
    var password: String
    var myActivityIds: [String]?
    var joinedActivityIds: [String]?
    
    static func UserToDictionary(user: User) -> [String: Any] {
        return [
            "uuid": user.uuid,
            "username": user.username,
            "email": user.email,
            "password": user.password,
            "myActivityIds": user.myActivityIds ?? [],
            "joinedActivityIds": user.joinedActivityIds ?? []
        ]
    }
    
    static func DictionaryToUser(dictionary: [String: Any]) -> User {
        let uuid = dictionary["uuid"] as! String
        let username = dictionary["username"] as! String
        let email = dictionary["email"] as! String
        let password = dictionary["password"] as! String
        let myActivityIds = dictionary["myActivityIds"] as? [String]? ?? []
        let joinedActivityIds = dictionary["joinedActivityIds"] as? [String]? ?? []
        
        return User(uuid: uuid, username: username, email: email, password: password, myActivityIds: myActivityIds, joinedActivityIds: joinedActivityIds)
    }
}
