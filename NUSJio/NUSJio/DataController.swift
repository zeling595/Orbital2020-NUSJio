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
    
    let db = Firestore.firestore()
    let activitiesCollection = Firestore.firestore().collection("activities")
    let usersCollection = Firestore.firestore().collection("users")
    
    // MARK: Fetch Activities
    func fetchSingleActivity(activityId: String, completion: @escaping (Activity?) -> Void) {
        let activityRef = activitiesCollection.document("activity-\(activityId)")
        activityRef.getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting activity: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                    let activity = Activity.DictionaryToActivity(dictionary: data)
                    completion(activity)
                }
            }
        }
    }
    
    func fetchAllActivities(completion: @escaping ([Activity]?) -> Void) {
        let database = Firestore.firestore();
        var activitiesForExplore: [Activity] = []
        database.collection("activities").getDocuments{ (snapshot, error) in
            if let error = error {
                print("error fetching activities: \(error)")
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    let activity = Activity.DictionaryToActivity(dictionary: document.data())
                    activitiesForExplore.append(activity)
                }
                // if snapshot empty, completion handler is not run???
                completion(activitiesForExplore.sorted { (acticity1, activity2) -> Bool in
                    // need to fix when there is no time
                    return acticity1.time?.compare(activity2.time!) == .orderedAscending
                })
            } else {
                print("snapshot is empty")
            }
            
            
        }
    }
    
    // new fetch activities for explore
    // state open, >= today
    func fetchActivitiesForExplore(completion: @escaping ([Activity]?) -> Void) {
        let database = Firestore.firestore();
        var activitiesForExplore: [Activity] = []
        database.collection("activities")
            .whereField("state", isEqualTo: "open")
            .whereField("time", isGreaterThanOrEqualTo: Date().onlyDate!)
            .getDocuments{ (snapshot, error) in
            if let error = error {
                print("error fetching activities: \(error)")
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    let activity = Activity.DictionaryToActivity(dictionary: document.data())
                    activitiesForExplore.append(activity)
                }
                // if snapshot empty, completion handler is not run???
                completion(activitiesForExplore.sorted { (acticity1, activity2) -> Bool in
                    // need to fix when there is no time
                    return acticity1.time?.compare(activity2.time!) == .orderedAscending
                })
            } else {
                print("snapshot is empty")
            }
            
            
        }
    }

    func fetchMyActivities(user: User, resultHandler: @escaping ([[Activity]]?) -> Void) {
        var activities2DArray: [[Activity]] = []
        var todayActivities: [Activity] = []
        var upcomingActivities: [Activity] = []
        
        // get user id
        let userId = user.uuid
        
        // query all activities where hostid == user id
        // TODO where date is today or in the future
        activitiesCollection
             .whereField("hostId", isEqualTo: userId)
             .whereField("state", in: ["open", "closed"])
             .whereField("time", isGreaterThanOrEqualTo: Date().onlyDate!)
             .getDocuments { (snapshot, error) in
             if let error = error {
                 print(error.localizedDescription)
             } else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for document in snapshot.documents {
                        let myActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        // print(myActivity)
                        let calender = Calendar.current
                        if let time = myActivity.time {
                            // got time
                            if calender.isDateInToday(time) {
                                todayActivities.append(myActivity)
                            } else {
                                upcomingActivities.append(myActivity)
                            }
                        } else {
                            // no time
                            upcomingActivities.append(myActivity)
                        }
                    }
                    // completion here
                    activities2DArray.append(todayActivities)
                    activities2DArray.append(upcomingActivities)
                } else {
                    print("result is empty")
                }
                resultHandler(activities2DArray)
            }
        }
    }
    
    func fetchJoinedActivities(user: User, resultHandler: @escaping ([[Activity]]?) -> Void) {
        // get user id
        let userId = user.uuid
        print(userId)
        
        var activities2DArray: [[Activity]] = []
        var todayActivities: [Activity] = []
        var upcomingActivities: [Activity] = []
        
        activitiesCollection
             .whereField("participantIds", arrayContains: userId)
             .whereField("state", in: ["open", "closed"])
             .whereField("time", isGreaterThanOrEqualTo: Date().onlyDate!)
             .getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for document in snapshot.documents {
                        let joinedActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        // print(myActivity)
                        let calender = Calendar.current
                        if let time = joinedActivity.time {
                            // got time
                            if calender.isDateInToday(time) {
                                todayActivities.append(joinedActivity)
                            } else {
                                upcomingActivities.append(joinedActivity)
                            }
                        } else {
                            // no time
                            upcomingActivities.append(joinedActivity)
                        }
                    }
                    activities2DArray.append(todayActivities)
                    activities2DArray.append(upcomingActivities)
                } else {
                    print("snapshot is empty")
                }
                resultHandler(activities2DArray)
            }
        }
    }
    
    func fetchUserActivitiesSectioned(user: User, completion: @escaping ([[Activity]]?) -> Void) {
        let operationQueue = OperationQueue()
        
        var activities2DArr: [[Activity]] = []
        var todayActivities: [Activity] = []
        var upcomingActivities: [Activity] = []

        let operation1 = BlockOperation {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.fetchMyActivities(user: user) {
                result in
                if let result = result, !result.isEmpty {
                    todayActivities.append(contentsOf: result[0])
                    upcomingActivities.append(contentsOf: result[1])
                }
                dispatchGroup.leave()
            }
            // wait until anAsyncMethod is completed
            dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        }

        let operation2 = BlockOperation {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.fetchJoinedActivities(user: user) {
                result in
                if let result = result, !result.isEmpty {
                    todayActivities.append(contentsOf: result[0])
                    upcomingActivities.append(contentsOf: result[1])
                }
                dispatchGroup.leave()
            }
            // wait until anotherAsyncMethod is completed
            dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        }

        let completionOperation = BlockOperation {
            // send all results to completion callback
            let sortedTodayActivities = todayActivities.sorted(by: { (activity1, activity2) -> Bool in
                return activity1.time?.compare(activity2.time!) == .orderedAscending
            })
            let sortedUpcomingActivities = upcomingActivities.sorted(by: { (activity1, activity2) -> Bool in
                return activity1.time?.compare(activity2.time!) == .orderedAscending
            })
            
            activities2DArr.append(sortedTodayActivities)
            activities2DArr.append(sortedUpcomingActivities)
            completion(activities2DArr)
        }

        // configuring interoperation dependencies
        operation2.addDependency(operation1)
        completionOperation.addDependency(operation2)

        operationQueue.addOperations([operation1, operation2, completionOperation], waitUntilFinished: false)
    }
    
    func fetchAllMyActivities(userId: String, completion: @escaping ([Activity]?) -> Void) {
        var allMyActivities: [Activity] = []
        
        // query all activities where hostid == user id
        activitiesCollection
             .whereField("hostId", isEqualTo: userId)
             .getDocuments { (snapshot, error) in
             if let error = error {
                 print(error.localizedDescription)
             } else {
                 if let snapshot = snapshot, !snapshot.isEmpty {
                     for document in snapshot.documents {
                        let myActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        allMyActivities.append(myActivity)
                    }
                    completion(allMyActivities)
                }
            }
        }
    }
    
    func fetchLikedActivities(userId: String, completion: @escaping ([Activity]?) -> Void) {
        var likedActivities: [Activity] = []

        activitiesCollection
             .whereField(Activity.likedByKey, arrayContains: userId)
             .getDocuments { (snapshot, error) in
             if let error = error {
                 print(error.localizedDescription)
             } else {
                 if let snapshot = snapshot, !snapshot.isEmpty {
                     for document in snapshot.documents {
                        let myActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        likedActivities.append(myActivity)
                    }
                    completion(likedActivities)
                }
            }
        }
    }
    
    func fetchMyCompletedActivities(userId: String, resultHandler: @escaping ([Activity]?) -> Void) {
        var myPastActivities: [Activity] = []
    
        activitiesCollection
             .whereField("hostId", isEqualTo: userId)
             .whereField("state", isEqualTo: "completed")
             .getDocuments { (snapshot, error) in
             if let error = error {
                 print(error.localizedDescription)
             } else {
                 if let snapshot = snapshot, !snapshot.isEmpty {
                     for document in snapshot.documents {
                        let myActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        myPastActivities.append(myActivity)
                    }
                    resultHandler(myPastActivities)
                 } else {
                    resultHandler(myPastActivities)
                }
            }
        }
    }
    
    func fetchJoinedCompletedActivities(userId: String, resultHandler: @escaping ([Activity]?) -> Void) {
        
        var joinedPastActivities: [Activity] = []
        
        activitiesCollection
             .whereField("participantIds", arrayContains: userId)
             .whereField("state", isEqualTo: "completed")
             .getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for document in snapshot.documents {
                        // print("\(document.documentID) => \(document.data())")
                        let joinedActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        // print(myActivity)
                        joinedPastActivities.append(joinedActivity)
                        }
                    resultHandler(joinedPastActivities)
                } else {
                    resultHandler(joinedPastActivities)
                }
            }
        }
    }
    
    func fetchCompletedActivities(userId: String, completion: @escaping ([Activity]?) -> Void) {
        let operationQueue = OperationQueue()

        var completedActivities: [Activity] = []

        let operation1 = BlockOperation {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.fetchMyCompletedActivities(userId: userId) {
                result in
                if let result = result, !result.isEmpty {
                    completedActivities.append(contentsOf: result)
                }
                dispatchGroup.leave()
            }
            // wait until anAsyncMethod is completed
            dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        }

        let operation2 = BlockOperation {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.fetchJoinedCompletedActivities(userId: userId) {
                result in
                if let result = result, !result.isEmpty {
                    completedActivities.append(contentsOf: result)
                }
                dispatchGroup.leave()
            }
            // wait until anotherAsyncMethod is completed
            dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        }

        let completionOperation = BlockOperation {
            // send all results to completion callback
            let sortedCompletedActivities = completedActivities.sorted(by: { (activity1, activity2) -> Bool in
                return activity1.time?.compare(activity2.time!) == .orderedAscending
            })
            
            completion(sortedCompletedActivities)
        }

        // configuring interoperation dependencies
        operation2.addDependency(operation1)
        completionOperation.addDependency(operation2)

        operationQueue.addOperations([operation1, operation2, completionOperation], waitUntilFinished: false)
    }
    
    // for milestone 2, currently not in use
    func fetchUserActivities(user: User, completion: @escaping ([Activity]?) -> Void) {
        var activitiesToDisplay: [Activity] = []
        // get user id
        let userId = user.uuid
        
        // query all activities where hostid == user id
        activitiesCollection.whereField("hostId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for document in snapshot.documents {
                        // print("\(document.documentID) => \(document.data())")
                        let myActivity = Activity.DictionaryToActivity(dictionary: document.data())
                        // print(myActivity)
                        activitiesToDisplay.append(myActivity)
                    }
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
    
    // MARK: User
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        let userDocRef = usersCollection.document("user-\(userId)")
        // print("(print from data controller) fetch user \(userId)")
        userDocRef.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists,
                let data = snapshot.data() else {return}
            // get out all data and make it to an user
            let user = User.DictionaryToUser(dictionary: data)
            completion(user)
        }
    }
    
    func updateUserProfileImageURL(userId: String, imageURL: String) {
        let userDocRef = usersCollection.document("user-\(userId)")
        userDocRef.updateData([User.profilePictureURLStrKey : imageURL]) { (error) in
            if let error = error {
                print("Error saving activity to activities collection: \(error.localizedDescription)")
            }
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
        
        let participantIds = Array(activity.participantsInfo.keys)
        for participantId in participantIds {
            let participantDocRef = self.usersCollection.document("user-\(participantId)")
            participantDocRef.updateData(["joinedActivityIds": FieldValue.arrayUnion([activity.uuid])]) { (error) in
                if let error = error {
                    print("Error saving activity to host user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func joinActivity(activity: Activity, userId: String, profilePicURL: String, completion: @escaping (Activity?) -> Void) {
        let db = Firestore.firestore()
        let activityDocRef = activitiesCollection.document("activity-\(activity.uuid)")
        let userDocRef = usersCollection.document("user-\(userId)")
        
        let numOfParticipants = activity.participantsInfo.count
       
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let activityDocSnapshot: DocumentSnapshot
            do {
                try activityDocSnapshot = transaction.getDocument(activityDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // check whether the participants number is most updated, actually no need to check cuz previously update no., now no need alr
            guard let updatedParticipants = activityDocSnapshot.data()?["participantIds"] as? [String], updatedParticipants.count == numOfParticipants else {return nil}
            
            // update number of participants, participants array
            var participantsInfo = activity.participantsInfo
            // update swift dic
            participantsInfo[userId] = profilePicURL
            activityDocRef.updateData([
                "participantIds": FieldValue.arrayUnion([userId]),
                "participantsInfo" : participantsInfo
            ]) { (error) in
                if let error = error {
                    print("Error joining activity: \(error.localizedDescription)")
                }
            }
            
            // update user's joined activities array
            userDocRef.updateData(["joinedActivityIds" : FieldValue.arrayUnion([activity.uuid])]) { (error) in
                if let error = error {
                    print("Error updating user's joined activity: \(error.localizedDescription)")
                }
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction to join failed: \(error)")
            } else {
                print("Transaction to join successfully committed!")
            }
        }
        
        activityDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching updated activity: \(error.localizedDescription)")
            } else {
                if let document = document {
                    if let dataDic =  document.data() {
                        let updatedActivity = Activity.DictionaryToActivity(dictionary: dataDic)
                        completion(updatedActivity)
                    } else {
                        print("No document data found")
                        completion(nil)
                    }
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }
    
    func changeActivityState(activity: Activity, changeTo state: ActivityState) {
        // update the activity state in back end
        let activityDocRef = activitiesCollection.document("activity-\(activity.uuid)")
        let stateStr = state.rawValue
        activityDocRef.updateData(["state" : stateStr]) { (error) in
            if let error = error {
                print("Error changing activity state: \(error.localizedDescription)")
            }
        }
    }
    
    func postponeActivity(activity: Activity, newDate: Date) {
        let activityDocRef = activitiesCollection.document("activity-\(activity.uuid)")
        activityDocRef.updateData([Activity.timeKey : Timestamp(date: newDate)]) { (error) in
            if let error = error {
                print("Error changing activity state: \(error.localizedDescription)")
            }
        }
    }
    
    func likeActivity(activityId: String, userId: String, completion: @escaping (Bool) -> Void) {
        // Get new write batch
        let batch = db.batch()
        
        // update user
        let userDocRef = usersCollection.document("user-\(userId)")
        userDocRef.updateData([User.likedActivityIdsKey: FieldValue.arrayUnion([activityId])]) { (error) in
            if let error = error {
                print("Error liking an activity: \(error.localizedDescription)")
            } else {
                let flag = true
                completion(flag)
            }
        }
        
        // update activity
        let activityDocRef = activitiesCollection.document("activity-\(activityId)")
        activityDocRef.updateData([Activity.likedByKey: FieldValue.arrayUnion([userId])]) { (error) in
            if let error = error {
                print("Error liking an activity: \(error.localizedDescription)")
            } else {
                let flag = true
                completion(flag)
            }
        }

        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
    
    func unlikeActivity(activityId: String, userId: String, completion: @escaping (Bool) -> Void) {
        // Get new write batch
        let batch = db.batch()
        
        // update user
        let userDocRef = usersCollection.document("user-\(userId)")
        userDocRef.updateData([User.likedActivityIdsKey : FieldValue.arrayRemove([activityId])]) { (error) in
            if let error = error {
               print("Error unliking an activity: \(error.localizedDescription)")
            } else {
                let flag = true
                completion(flag)
            }
        }
        // update activity
        let activityDocRef = activitiesCollection.document("activity-\(activityId)")
        activityDocRef.updateData([Activity.likedByKey: FieldValue.arrayRemove([userId])]) { (error) in
            if let error = error {
                print("Error liking an activity: \(error.localizedDescription)")
            } else {
                let flag = true
                completion(flag)
            }
        }
 
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
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
//        if let participantIds = Array(activityToBeDeleted.participantsInfo.keys) {
//            numOfParticipants = participantIds.count
//            participantRefArr = participantIds.map {usersCollection.document("user-\($0)")}
//        } else {
//            numOfParticipants = 0
//            participantRefArr = []
//        }
        let participantIds = Array(activityToBeDeleted.participantsInfo.keys)
        numOfParticipants = participantIds.count
        participantRefArr = participantIds.map {usersCollection.document("user-\($0)")}
        
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
                print("Transaction to delete failed: \(error)")
            } else {
                print("Transaction to delete successfully committed!")
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
                print("Put is complete and I got this back: \(String(describing: downloadMetadata))")
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
    
    func uploadProfilePictureAndGetUrl(image: UIImage, completion: @escaping (String?) -> Void) {
        // create random image without overriding each other
        let randomID = UUID.init().uuidString
        // get a cloud storage reference
        let uploadRef = Storage.storage().reference(withPath: "users/\(randomID).jpg")
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

