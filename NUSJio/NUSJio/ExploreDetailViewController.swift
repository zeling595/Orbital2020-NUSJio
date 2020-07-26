//
//  ExploreDetailViewController.swift
//  NUSJio
//
//  Created by 程及雨晴 on 29/6/20.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout
import FirebaseAuth

class ExploreDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var activity: Activity!
    var activityIndexPath: IndexPath!
    weak var delegate: ActivityDetailDelegate?
    let dataController = DataController()
    var currentUser: User!
    
    var tags: [String] {
        return Activity.getTagsArray(activity: activity)
    }
    
    var participantProfilePics: [String] {
        return Array(activity.participantsInfo.values)
    }
    
    var liked: Bool!
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var tagsCollectionView: UICollectionView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var participantsCollectionView: UICollectionView!
    @IBOutlet var participantLabel: UILabel!
    
    @IBOutlet var buttonStackView: UIStackView!
    
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
                } else {
                    print("cannot fetch user")
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
        let chatWithHostButton = createButton(title: "Chat", imageName: "message")
        // chatWithHostButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
        self.chatWithHostButton = chatWithHostButton
        // chatWithHostButton.backgroundColor = UIColor.systemBlue
        
        let joinButton = createButton(title: "Join", imageName: "person.2")
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        self.joinButton = joinButton
        // joinButton.backgroundColor = UIColor.systemRed
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
    
    // MARK: collection view data source
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
    
    // TODO: edit and delete here unless user cannot search its own activity
    
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
    
    // TODO: actually should do backend check instead
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
    
    
    @IBAction func unwindToExplore(segue: UIStoryboardSegue) {
       
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
