//
//  MeViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/22.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var profilePicImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    
    var currentUser: User!
    // implement state change listener if got time
    // var handle: AuthStateDidChangeListenerHandle?
    
    let dataController = DataController()
    
    var activitiesByMe: [Activity] = []
       
    var likedActivities: [Activity] = []
       
    var completedActivities: [Activity] = []
    
    lazy var dataToDisplay = activitiesByMe
    
    override func viewWillAppear(_ animated: Bool) {
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                    self.usernameLabel.text = user.username
                    
                    self.dataController.fetchImage(imageURL: user.profilePictureURLStr!) { (data) in
                        if let data = data {
                            self.profilePicImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
            
            dataController.fetchLikedActivities(userId: uuid) { (activities) in
                if let activities = activities {
                    self.likedActivities = activities
                    print(activities)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("No liked activities")
                    self.likedActivities = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
               
            }
            
            dataController.fetchAllMyActivities(userId: uuid) { (activities) in
                if let activities = activities {
                    self.activitiesByMe = activities
                    self.dataToDisplay = activities
                    self.tableView.reloadData()
                } else {
                    print("No activities by me")
                    self.activitiesByMe = []
                    self.tableView.reloadData()
                }
            }
            
           
            
            dataController.fetchCompletedActivities(userId: uuid) { (activities) in
                if let activities = activities {
                    self.completedActivities = activities
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("No completed Activities")
                    self.completedActivities = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            
        } else {
            print("oops no current user")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpProfileImageView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if let tableView = tableView as? SelfSizingTableView {
            tableView.maxHeight = 506
        }
        navigationItem.title = "Me"
        
        setUpSegmentControl()
    }
    
    func setUpProfileImageView() {
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height / 2
        profilePicImageView.contentMode = UIView.ContentMode.scaleToFill
        profilePicImageView.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profilePicImageView.isUserInteractionEnabled = true
        profilePicImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        // Your action
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)})
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler:  { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profilePicImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        let resizedImage = self.profilePicImageView.image!.resized(toWidth: 120)!
        dataController.uploadProfilePictureAndGetUrl(image: resizedImage) { (imageURL) in
            if let imageURL = imageURL {
                self.dataController.updateUserProfileImageURL(userId: self.currentUser.uuid, imageURL: imageURL)
            }
        }
    }
    
    func setUpSegmentControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitle("Activites By Me", forSegmentAt: 0)
        segmentedControl.setTitle("Liked", forSegmentAt: 1)
        segmentedControl.insertSegment(withTitle: "Completed", at: 2, animated: false)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Styles.themeOrange], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Styles.themeBlue], for: .normal)
    }
    
    @IBAction func handleSegmentChange(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            dataToDisplay = activitiesByMe
        case 1:
            dataToDisplay = likedActivities
        case 2:
            dataToDisplay = completedActivities
        default:
            print("something wrong with segment control")
        }
        
        tableView.reloadData()
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
          
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
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
    
    func configure(cell: MeTableViewCell, activity: Activity) {
        var imageName: String = ""
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.indicatorButton.setTitle(" Mine", for: .normal)
            imageName = "smiley"
        case 1:
            cell.indicatorButton.setTitle(" Liked", for: .normal)
            imageName = "heart"
        case 2:
            cell.indicatorButton.setTitle(" Completed", for: .normal)
            imageName = "checkmark.circle"
        default:
            print("something weird happened")
        }
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .light, scale: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        cell.indicatorButton.setImage(image, for: .normal)
        cell.indicatorButton.tintColor = Styles.themeOrange
        cell.indicatorButton.setTitleColor(Styles.themeOrange, for: .normal)
        cell.indicatorButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.coverImageView.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
        cell.coverImageView.layer.masksToBounds = true
        cell.mainView.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
        cell.mainView.layer.masksToBounds = true
        cell.mainView.backgroundColor = Styles.cellGry
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.text = activity.title
        if let time = activity.time {
            cell.timeLabel.text = Activity.timeDateFormatter.string(from: time)
        } else {
           cell.timeLabel.text = "No fixed time yet"
        }
        
        if let location = activity.location {
            cell.locationLabel.text = location
        } else {
            cell.locationLabel.text = "No fixed location yet"
        }
        dataController.fetchImage(imageURL: activity.imageURLStr) { (data) in
            if let data = data {
                cell.coverImageView.image = UIImage(data: data)
            } else {
                print("Error fetching image data")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "meTableViewCell", for: indexPath) as? MeTableViewCell else {
            fatalError("cannot dequeue cell")
        }
        let activity = dataToDisplay[indexPath.row]
        configure(cell: cell, activity: activity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "meActivityDetailSegue",
            let activityDetailController = segue.destination as? ActivityDetailViewController {
            let indexPath = tableView.indexPathForSelectedRow!
            // let selectedActivity = activities[indexPath.row]
            let selectedActivity = dataToDisplay[indexPath.row]
            activityDetailController.activity = selectedActivity
            activityDetailController.activityIndexPath = indexPath
            // does not allow user to delete activity here
            // activityDetailController.delegate = self
        }
    }

}
