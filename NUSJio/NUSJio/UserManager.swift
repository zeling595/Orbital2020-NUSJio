//
//  UserManager.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/26.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

protocol UserManagerProtocol: class {
    func getSignedInUser() -> User?
    func signIn(email: String, password: String, loginVC: LogInViewController)
}

class UserManager: UserManagerProtocol {
    fileprivate var signedInUser: User?
    
    let usersCollection = Firestore.firestore().collection("users")
    
    func getSignedInUser() -> User? {
        return signedInUser
    
    }
    
    func signIn(email: String, password: String, loginVC: LogInViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if error != nil {
                // could not log in
                loginVC.errorLabel.text = error!.localizedDescription
                loginVC.errorLabel.alpha = 1.0
            } else {
                // sign in successfully
                guard let firebaseUser = authResult?.user,
                    let email = firebaseUser.email else {return}
                let uuid = firebaseUser.uid
                // let username =
                // TODO hash password
                // create a user
                self?.signedInUser = User(uuid: uuid, username: "", email: email, password: password, myActivityIds: nil, joinedActivityIds: nil)
                // transit to home screen
                loginVC.transitionToHomepage()
            }
        }
    }
}
