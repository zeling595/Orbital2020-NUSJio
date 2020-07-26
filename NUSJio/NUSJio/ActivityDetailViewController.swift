//
//  ActivityDetailViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/11.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout
import FirebaseAuth

protocol ActivityDetailDelegate: class {
    func deleteActivity(activityIndexPath: IndexPath)
}

class ActivityDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let dataController = DataController()
    var currentUser: User! // the host, havent implemented fetch yet
    
    var liked: Bool!
    var activity: Activity!
    var activityIndexPath: IndexPath?
    var isDeleteAction = false
    var isEditAction = false
    var isCreateAction = false
    
    var tags: [String] {
        return Activity.getTagsArray(activity: activity)
    }
    
    var participantProfilePics: [String] {
        return Array(activity.participantsInfo.values)
    }
    
    weak var delegate: ActivityDetailDelegate?
    weak var tabBarDelegate: CustomTabBarDelegate?
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var tagsCollectionView: UICollectionView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var participantsCollectionView: UICollectionView!
    @IBOutlet var participantLabel: UILabel!
    
    @IBOutlet var buttonStackView: UIStackView!
    
    // for my activities
    var editButton: UIButton?
    var viewChatButton: UIButton?
    // middle button
    var jioButton: UIButton?
    var completeButton: UIButton? // can only mark complete if activity is today
   
    // for joined activity
    var chatWithHostButton: UIButton?
    var joinButton: UIButton?
    var likeButton: UIButton?
    
    override func viewDidLoad() {
        updateUI()
        super.viewDidLoad()
        
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                    self.liked =  self.currentUser.likedActivityIds?.contains(self.activity.uuid) ?? false
                    DispatchQueue.main.async {
                        self.setUpButtons()
                    }
                }
            }
        }
        
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        
        participantsCollectionView.delegate = self
        participantsCollectionView.dataSource = self
        
        let alignedFlowLayout = tagsCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        
        // make cell self-sizing
        if let collectionViewLayout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        tagsCollectionView.reloadData()
        tagsCollectionView.layoutIfNeeded()
    }
    
    // MARK: UI
    func updateUI() {
        titleLabel.text = activity.title
        timeLabel.text = Activity.timeDateFormatter.string(for: activity.time)
        locationLabel.text = activity.location
        descriptionTextView.text = activity.description
        descriptionTextView.isEditable = false
        coverImageView.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
        coverImageView.layer.masksToBounds = true
        dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
            if let imageData = imageData {
                self.coverImageView.image = UIImage(data: imageData)
            }
        })
        if activity.participantsInfo.count == 0 {
            participantLabel.text = "There is no participant yet. Be the first one to join"
        } else {
            participantLabel.text = "Participants"
        }
    }
    
    func updateCompleteButtonState() {
        if activity.state == .completed {
            completeButton?.isEnabled = false
            completeButton?.setTitleColor(UIColor.gray, for: .disabled)
            completeButton?.tintColor = UIColor.gray
        } else {
            print("activity is not completed")
        }
    }
    
    func updateJoinButtonState() {
        if !canJoin() {
            joinButton?.isEnabled = false
            joinButton?.setTitleColor(UIColor.gray, for: .normal)
            joinButton?.tintColor = UIColor.gray
        }
    }
    
    func updateLikeButtonState() -> UIButton {
        var updateLikeButton: UIButton
        if liked {
            updateLikeButton = createButton(title: "Unlike", imageName: "heart.fill")
            updateLikeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        } else {
            updateLikeButton = createButton(title: "Like", imageName: "heart")
            updateLikeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        }
        return updateLikeButton
    }
    
    func setUpButtonForMyActivities() {
        var middleButton: UIButton
        if activity.state == .closed {
            // complete button
            let completeButton = createButton(title: "Complete", imageName: "checkmark.circle")
            completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
            self.completeButton = completeButton
            updateCompleteButtonState()
            middleButton = completeButton
        } else if activity.state == .open {
            // jio button
            let jioButton = createButton(title: "Jio", imageName: "sun.min")
            self.joinButton = jioButton
            jioButton.addTarget(self, action: #selector(jioButtonTapped), for: .touchUpInside)
            middleButton = jioButton
        } else {
            let completeButton = createButton(title: "Complete", imageName: "checkmark.circle")
            self.completeButton = completeButton
            updateCompleteButtonState()
            middleButton = completeButton
        }
        
        let viewChatButton = createButton(title: "Chat", imageName: "message")
        self.viewChatButton = viewChatButton
        // viewChatButton.addTarget(self, action: #selector(viewChatButtonTapped), for: .touchUpInside)
        
        
        let editButton = createButton(title: "Edit", imageName: "pencil")
        self.editButton = editButton
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        
        buttonStackView.addArrangedSubview(viewChatButton)
        buttonStackView.addArrangedSubview(middleButton)
        buttonStackView.addArrangedSubview(editButton)
    }
    
    func setUpButtonForJoinedActivities() {
        let chatWithHostButton = createButton(title: "Chat", imageName: "message")
        self.chatWithHostButton = chatWithHostButton
        
        let joinButton = createButton(title: "Join", imageName: "person.2")
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        self.joinButton = joinButton
        updateJoinButtonState()
        
        let likeButton = updateLikeButtonState()
        self.likeButton = likeButton
        
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 20
        
        buttonStackView.addArrangedSubview(chatWithHostButton)
        buttonStackView.addArrangedSubview(joinButton)
        buttonStackView.addArrangedSubview(likeButton)
    }
    
    func setUpButtons() {
        if activity.hostId == currentUser.uuid {
            setUpButtonForMyActivities()
        } else {
            setUpButtonForJoinedActivities()
        }
    }
    
    // MARK: Button method
    @objc func completeButtonTapped() {
        // display an alert
        let title = "Complete Jio"
        let msg = "This action will remove your Jio from \"Explore Tab\" and \"My Activities Tab\". Press \"OK\" to complete a Jio."
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // change state from close to complete
            self.dataController.changeActivityState(activity: self.activity, changeTo: .completed)
            self.completeButton?.isEnabled = false
            self.completeButton?.setTitleColor(UIColor.gray, for: .disabled)
            self.completeButton?.tintColor = UIColor.gray
            // TODO: transition to leave a comment page?
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func jioButtonTapped() {
        // display an alert
        let title = "Finalise Jio"
        let msg = "This action will remove your Jio from \"Explore Tab\". Press \"OK\" once you decide to stop looking for new participants."
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // change state from open to close
            self.dataController.changeActivityState(activity: self.activity, changeTo: .closed)
            // create new button
            let completeButton = self.createButton(title: "Complete", imageName: "checkmark.circle")
            completeButton.addTarget(self, action: #selector(self.completeButtonTapped), for: .touchUpInside)
            self.completeButton = completeButton
            // remove jio button, add complete button
            self.buttonStackView.removeArrangedSubview(self.jioButton!)
            self.jioButton?.removeFromSuperview()
            self.buttonStackView.addArrangedSubview(completeButton)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc @IBAction func joinButtonTapped(_ sender: UIButton) {
        // update backend
        let uuid = currentUser.uuid
        let profilePicURL = currentUser.profilePictureURLStr!
        
        // check if the user already joined the activity
        // TODO: reinforce with security rule
        if canJoin() {
            dataController.joinActivity(activity: activity, userId: uuid, profilePicURL: profilePicURL) { (activity) in
                if let updatedActivity = activity {
                    self.activity = updatedActivity
                    // not sure whether participants array is updated when activity update
                    // view controller not updated
                    self.participantsCollectionView.reloadData()
                    self.updateUI()
                    // disable the button
                    self.joinButton!.isEnabled = false
                    self.joinButton!.setTitleColor(UIColor.gray, for: .normal)
                    self.joinButton!.tintColor = UIColor.gray
                }
            }
        } else {
            // display a warning
        }
    }
    
    @objc @IBAction func likeButtonTapped(_ sender: UIButton) {
        // update backend
        if liked {
            // unlike
            dataController.unlikeActivity(activityId: activity.uuid, userId: currentUser.uuid) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.liked = false
                        self.buttonStackView.removeArrangedSubview(self.likeButton!)
                        self.likeButton?.removeFromSuperview()
                        let likeButton = self.updateLikeButtonState()
                        self.likeButton = likeButton
                        self.buttonStackView.addArrangedSubview(likeButton)
                        
                    }
                }
            }
        } else {
            // like
           dataController.likeActivity(activityId: activity.uuid, userId: currentUser.uuid) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.liked = true
                        self.buttonStackView.removeArrangedSubview(self.likeButton!)
                        self.likeButton?.removeFromSuperview()
                        let likeButton = self.updateLikeButtonState()
                        self.likeButton = likeButton
                        self.buttonStackView.addArrangedSubview(likeButton)
                    }
                }
            }
        }
    }
    
    func userJoinedAlready() -> Bool {
        let participantIds = Array(activity.participantsInfo.keys)
        if participantIds.count == 0 {
            return false
        } else {
            if participantIds.contains(currentUser.uuid) {
                return true
            } else {
                return false
            }
        }
    }
    
    func canJoin() -> Bool {
       if userJoinedAlready() {
           return false
       } else {
           if let numOfParticipants = activity.numOfParticipants {
               return numOfParticipants > activity.participantsInfo.count
           } else {
               // no. of participants does not exist -> no limit
               return true
           }
        }
    }
    
    func createButton(title: String, imageName: String) -> UIButton {
        let button = UIButton()
        let size: CGFloat = 100
        button.frame = CGRect(x: size, y: size, width: size, height: size)
        button.setTitle(title, for: .normal)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: largeConfig)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Styles.themeOrange
        button.setTitleColor(Styles.themeOrange, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerVertically()
        return button
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        // show alert
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete this activity?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.delegate?.deleteActivity(activityIndexPath: self.activityIndexPath!)
            self.navigationController?.popViewController(animated: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc @IBAction func editButtonTapped(_ sender: UIButton) {
        let tabBarVC = view.window?.rootViewController as? CustomTabBarController
        tabBarVC?.goTo(index: 2, activity: activity)
    }
    
    // MARK: Collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.tagsCollectionView {
            return tags.count
        } else {
            return participantProfilePics.count
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.tagsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
            cell.tagLabel.text = tags[indexPath.item]
            cell.tagLabel.textColor = UIColor.white
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantCollectionViewCell", for: indexPath) as! ParticipantCollectionViewCell
            // fetch data and configure here
            let profilePicURL = participantProfilePics[indexPath.row]
            dataController.fetchImage(imageURL: profilePicURL) { (data) in
                if let data = data {
                    cell.participantImageView.image = UIImage(data: data)
                    cell.participantImageView.layer.cornerRadius = cell.participantImageView.frame.height / 2
                    cell.participantImageView.layer.masksToBounds = true
                }
            }
            return cell
        }
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.editActivitySegue, let navController = segue.destination as? UINavigationController,
            let addActivityTableViewController = navController.topViewController as?
                AddActivityTableViewController {
            addActivityTableViewController.activity = activity
            
            // assign delegate, so delegate not nil???
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(identifier: "CustomTabBarController") as! CustomTabBarDelegate
            addActivityTableViewController.delegate = tabBarVC
            // print("(print from activity detail) prepare \(addActivityTableViewController.delegate)")
            
        }
    }

}
