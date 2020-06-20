//
//  ActivityController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/19.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class ActivityController {
    static let shared = ActivityController()
    let collection = Firestore.firestore().collection("activities")
    
    func fetchUserActivities() {
        
    }
    
    func saveActivity() {
        
    }
    
    func uploadImage() {
        
    }
    
    func downloadImage() {
        
    }
}
