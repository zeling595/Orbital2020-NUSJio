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
    var editButton: UIButton? {
        didSet {
            editButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    var viewChatButton: UIButton? {
        didSet {
            viewChatButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    var completeButton: UIButton? {
        didSet {
            completeButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    var jioButton:UIButton? {
        didSet {
            jioButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    var chatWithHostButton: UIButton? {
        didSet {
            chatWithHostButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    var joinButton: UIButton?{
        didSet {
            joinButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
    }
    
    
    override func viewDidLoad() {
        updateUI()
        super.viewDidLoad()
        
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
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
    
    func setUpButtons() {
        if activity.hostId == currentUser.uuid {

            // complete
            var middleButton: UIButton
            if activity.state == .closed {
                // complete button
                completeButton = UIButton()
                completeButton!.setTitle("Complete", for: .normal)
                completeButton!.setTitleColor(UIColor.white, for: .normal)
                completeButton!.translatesAutoresizingMaskIntoConstraints = false
                middleButton = completeButton!
                middleButton.backgroundColor = Styles.themeOrange
                middleButton.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
                
                // viewChatButton.addTarget(self, action: #selector(postponeButtonTapped), for: .touchUpInside)
            } else if activity.state == .open {
                // jio button
                jioButton = UIButton()
                jioButton!.setTitle("Jio", for: .normal)
                jioButton!.setTitleColor(UIColor.white, for: .normal)
                jioButton!.translatesAutoresizingMaskIntoConstraints = false
                middleButton = jioButton!
                middleButton.backgroundColor = Styles.themeOrange
                middleButton.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
                
                // jioButton.addTarget(cell, action: #selector(ActivityCell.jioButtonTapped), for: .touchUpInside)
                // updateJioButtonState(cell: cell, activity: activity)
            } else {
                // this block is useless because complete will not appear here
                completeButton = UIButton()
                completeButton!.setTitle("Complete", for: .normal)
                completeButton!.setTitleColor(UIColor.white, for: .normal)
                completeButton!.translatesAutoresizingMaskIntoConstraints = false
                completeButton!.isEnabled = true
                middleButton = completeButton!
                middleButton.backgroundColor = UIColor.lightGray
                middleButton.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
                
            }
            
            let viewChatButton = UIButton()
            viewChatButton.setTitle("View Chat", for: .normal)
            viewChatButton.setTitleColor(Styles.themeOrange, for: .normal)
            viewChatButton.translatesAutoresizingMaskIntoConstraints = false
            // viewChatButton.addTarget(self, action: #selector(postponeButtonTapped), for: .touchUpInside)
            self.viewChatButton = viewChatButton
            
            
            let editButton = UIButton()
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitleColor(Styles.themeOrange, for: .normal)
            editButton.translatesAutoresizingMaskIntoConstraints = false
            // jioButton.addTarget(cell, action: #selector(ActivityCell.jioButtonTapped), for: .touchUpInside)
            self.editButton = editButton
            // updateJioButtonState(cell: cell, activity: activity)
            
            buttonStackView.alignment = .fill
            buttonStackView.distribution = .fillEqually
            // buttonStackView.spacing = 8.0
            
            buttonStackView.addArrangedSubview(viewChatButton)
            buttonStackView.addArrangedSubview(middleButton)
            buttonStackView.addArrangedSubview(editButton)
        } else {
            let chatWithHostButton = UIButton()
            chatWithHostButton.setTitle("Chat With Host", for: .normal)
            chatWithHostButton.setTitleColor(Styles.themeOrange, for: .normal)
            chatWithHostButton.translatesAutoresizingMaskIntoConstraints = false
            // chatWithHostButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
            self.chatWithHostButton = chatWithHostButton
            
            let joinButton = UIButton()
            joinButton.setTitle("Join", for: .normal)
            joinButton.setTitleColor(UIColor.gray, for: .normal)
            joinButton.translatesAutoresizingMaskIntoConstraints = false
            // chatWithHostButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
            self.joinButton = joinButton
            self.joinButton!.isEnabled = false
            
            buttonStackView.alignment = .fill
            buttonStackView.distribution = .fillEqually
            // buttonStackView.spacing = 8.0
            
            buttonStackView.addArrangedSubview(chatWithHostButton)
            buttonStackView.addArrangedSubview(joinButton)
            
        }
    }
    
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
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let tabBarVC = view.window?.rootViewController as? CustomTabBarController
        tabBarVC?.goTo(index: 2, activity: activity)
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
