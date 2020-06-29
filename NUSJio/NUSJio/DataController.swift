//
//  ActivityController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/19.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import CryptoKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class DataController {

    let activitiesCollection = Firestore.firestore().collection("activities")
    let usersCollection = Firestore.firestore().collection("users")
    
    // MARK: Fetch Activities
    func fetchUserActivities(user: User, completion: @escaping ([Activity]?) -> Void) {
        var activitiesToDisplay: [Activity] = []
        // get user id
        let userId = user.uuid
        
        // query all activities where hostid == user id
        activitiesCollection.whereField("hostId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {return}
                for document in snapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                    let myActivity = Activity.DictionaryToActivity(dictionary: document.data())
                    print(myActivity)
                    activitiesToDisplay.append(myActivity)
                }
                completion(activitiesToDisplay.sorted { (acticity1, activity2) -> Bool in
                    // need to fix when there is no time
                    return acticity1.time?.compare(activity2.time!) == .orderedAscending
                })
            }
        }
        
        // query all activities where participants id contains user id
        activitiesCollection.whereField("participantIds", arrayContains: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {return}
                for document in snapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    // MARK: Fetch User
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        let userDocRef = usersCollection.document("user-\(userId)")
        print("(print from data controller) fetch user \(userId)")
        userDocRef.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists,
                let data = snapshot.data() else {return}
            // get out all data and make it to an user
            let user = User.DictionaryToUser(dictionary: data)
            completion(user)
        }
    }
    
    // MARK: Save and update
    func saveActivity(activity: Activity) {
        let activityDocRef = activitiesCollection.document("activity-\(activity.uuid)")
        let activityToSave = Activity.activityToDictionary(activity: activity)
        activityDocRef.setData(activityToSave) { (error) in
            if let error = error {
                print("Error saving activity to activities collection: \(error.localizedDescription)")
            }
        }
        
        let hostId = activity.hostId
        let userDocRef = usersCollection.document("user-\(hostId)")
        userDocRef.updateData(["myActivityIds": FieldValue.arrayUnion([activity.uuid])]) { (error) in
            if let error = error {
                print("Error saving activity to host user: \(error.localizedDescription)")
            }
        }
        
        guard let participantIds = activity.participantIds else {return}
        for participantId in participantIds {
            let participantDocRef = self.usersCollection.document("user-\(participantId)")
            participantDocRef.updateData(["joinedActivityIds": FieldValue.arrayUnion([activity.uuid])]) { (error) in
                if let error = error {
                    print("Error saving activity to host user: \(error.localizedDescription)")
                }
            }
        }
        
        
        
    }
    
    // MARK: Delete
    func deleteActivity(activityToBeDeleted: Activity) {
        
        let db = Firestore.firestore()
        // TODO: Only host can delete an activity
        let activityId = activityToBeDeleted.uuid
        let activityRef = activitiesCollection.document("activity-\(activityId)")
        
        let hostId = activityToBeDeleted.hostId
        let hostRef = usersCollection.document("user-\(hostId)")
        
        var numOfParticipants: Int
        var participantRefArr: [DocumentReference]
        if let participantIds = activityToBeDeleted.participantIds {
            numOfParticipants = participantIds.count
            participantRefArr = participantIds.map {usersCollection.document("user-\($0)")}
        } else {
            numOfParticipants = 0
            participantRefArr = []
        }
        
        // run a single transaction
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let activityDocSnapshot: DocumentSnapshot
            do {
                try activityDocSnapshot = transaction.getDocument(activityRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // check whether the participant number is the most updated, no need to check user
            guard let updatedParticipants = activityDocSnapshot.data()?["participantIds"] as? [String], updatedParticipants.count == numOfParticipants else {return nil}
            
            // run actual transaction
            // delete the activity
            transaction.deleteDocument(activityRef)
            // update host
            transaction.updateData(["myActivityIds" : FieldValue.arrayRemove([activityId])], forDocument: hostRef)
            // update all participants
            for participantRef in participantRefArr {
                transaction.updateData(["joinedActivityIds" : FieldValue.arrayRemove([activityId])], forDocument: participantRef)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
        // delete image when activity is completely deleted
        let imageRef = Storage.storage().reference(forURL: activityToBeDeleted.imageURLStr)
        imageRef.delete { (error) in
            if let error = error {
                print("Error deleting image: \(error)")
            }
        }
    }
    
    // MARK: Image
    // currently not in use
    func uploadImage(image: UIImage, progressView: UIProgressView) {
        // create random image without overriding each other
        // if using hashing the uuid is kind of useless?
        // let randomID = UUID.init().uuidString
        
        // convert uiimage into a data obj, jpeg type
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let hashedStr = SHA256.hash(data: imageData).description
        // get a cloud storage reference
        let uploadRef = Storage.storage().reference(withPath: "activities/\(hashedStr).jpg")
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        let taskReference = uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Error uploading image \(error.localizedDescription)")
            } else {
                print("Put is complete and I got this back: \(downloadMetadata)")
            }
        }
    }
        
    func uploadImageAndGetURL(image: UIImage, progressView: UIProgressView, completion: @escaping (String?) -> Void){
        // create random image without overriding each other
        let randomID = UUID.init().uuidString
        // get a cloud storage reference
        let uploadRef = Storage.storage().reference(withPath: "activities/\(randomID).jpg")
        // convert uiimage into a data obj, jpeg type
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
                
        let taskReference = uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Error uploading image \(error.localizedDescription)")
                return
            } else {
                print("Put is complete and I got this back: \(downloadMetadata)")
            }
            
            // can do this anytime after upload image
            uploadRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error generating the URL: \(error.localizedDescription)")
                    return
                }
                if let url = url {
                    print("Here is your download URL: \(url.absoluteString)")
                    completion(url.absoluteString)
                }
            }
            
        }
        
        //uploading task remove the observer automatically when they are done
        taskReference.observe(.progress) { [weak self] (snapshot) in
            guard let pctThere = snapshot.progress?.fractionCompleted else {return}
            print("You are \(pctThere) complete")
            // set the progress view
            progressView.progress = Float(pctThere)
        }
        
    }
    
    func fetchImage(imageURL: String, completion: @escaping (Data?) -> Void ) {
        let storageRef = Storage.storage().reference(forURL: imageURL)
        let taskReference = storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            if let data = data {
                // set image here
                // imageView.imag = UIImage(data: data)
                completion(data)
            }
        }
        // can observe progress, although not necessary?
    }
}

