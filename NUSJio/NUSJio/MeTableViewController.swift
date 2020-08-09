//
//  MeTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MeTableViewController: UITableViewController {

    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var uuidLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    
    var currentUser: User!
    // implement state change listener if got time
    // var handle: AuthStateDidChangeListenerHandle?
    
    let dataController = DataController()
    
    override func viewDidLoad() {
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height / 2
        profilePictureImageView.contentMode = UIView.ContentMode.scaleToFill
        profilePictureImageView.clipsToBounds = true
        
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                    self.usernameLabel.text = user.username
                    self.uuidLabel.text = user.uuid
                    self.emailLabel.text = user.email
                    self.passwordLabel.text = user.password
                    
                    self.dataController.fetchImage(imageURL: user.profilePictureURLStr!) { (data) in
                        if let data = data {
                            self.profilePictureImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        } else {
            print("oops no current user")
        }
        
        super.viewDidLoad()
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
          
    }

    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        // add an alert
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            self.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInNavigationController = storyboard.instantiateViewController(identifier: "LogInNavigationController") as? UINavigationController
            self.view.window?.rootViewController = logInNavigationController
            self.view.window?.makeKeyAndVisible()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        
        present(alertController, animated: true, completion: nil)
    }
   
}
