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
    @IBOutlet var cellForTableView: UITableViewCell!
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [" Activites By Me", "Liked Activities", "History"])
        return sc
    }()
    
    let segmentedTableView = UITableView(frame: .zero, style: .plain)
    
    let activitiesByMe = ["dinner", "breakfast", "lunch"]
    
    let likedActivities = ["swimming", "running", "static exercise"]
    
    let history = ["shopping", "movie", "hiking with friends"]
    
    var currentUser: User!
    // implement state change listener if got time
    // var handle: AuthStateDidChangeListenerHandle?
    
    let dataController = DataController()
    
    func setUpSegmentedTableView() {
        let stackView = UIStackView()
        
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 16.0
        
        stackView.addArrangedSubview(segmentedControl)
        stackView.addArrangedSubview(segmentedTableView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        cellForTableView.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: cellForTableView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: cellForTableView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: cellForTableView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cellForTableView.bottomAnchor).isActive = true
    }
    
    
    override func viewDidLoad() {
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height / 2
        profilePictureImageView.contentMode = UIView.ContentMode.scaleToFill
        profilePictureImageView.clipsToBounds = true
        
        setUpSegmentedTableView()
        
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
