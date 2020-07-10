//
//  MyActivitiesTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyActivitiesTableViewController: UITableViewController, ActivityDetailDelegate, ActivityCellDelegate {

    var activities = [Activity]()
    var currentUser: User!
    let dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        // get current user
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            // print("(print from my activities) uuid \(uuid)")
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                    // print("(print from my activities) \(self.currentUser)")
                    
                    self.dataController.fetchUserActivities(user: self.currentUser) { (fetchedActivities) in
                        if let fetchedActivities = fetchedActivities, !fetchedActivities.isEmpty {
                            self.activities = fetchedActivities
                            // print(fetchedActivities)
                            self.tableView.reloadData()
                        }
                        self.view.removeBluerLoader()
                    }
                    
                } else {
                    print("oops cannot fetch user")
                }
            }
        } else {
            print("oops no current user")
        }
        
        // remove separator
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        // self-sizing
        tableView.estimatedRowHeight = 350
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func deleteActivity(activityIndexPath: IndexPath) {
        dataController.deleteActivity(activityToBeDeleted: activities[activityIndexPath.row])
        activities.remove(at: activityIndexPath.row)
        tableView.deleteRows(at: [activityIndexPath], with: .fade)
    }
    
    func startButtonTapped(sender: ActivityCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            // need to change the appearance of the button, reference the personality quiz project
            var activity = activities[indexPath.row]
            activity.isComplete = true
            activities[indexPath.row] = activity
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            // save to disk
            // Activity.saveActivities(activities)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // learn how to do 2 sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activities.count == 0 {
            tableView.setEmptyView(title: "Create your own or explore more activities", message: "You activities will be here")
        } else {
            tableView.restore()
        }
        return activities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.activityCellIdentifier, for: indexPath) as? ActivityCell else {
            fatalError("Could not dequeue a cell")
        }

        // Configure the cell...
        cell.delegate = self
        cell.contentView.isUserInteractionEnabled = false
        let activity = activities[indexPath.row]
        // print(activity)
        cell.tags = Activity.getTagsArray(activity: activity)
        cell.tagsCollectionView.reloadData()
        cell.tagsCollectionView.layoutIfNeeded()
        updateCellUI(cell: cell, activity: activity)

        return cell
    }
    
    func updateCellUI(cell: ActivityCell, activity: Activity) {
        cell.layer.cornerRadius = 6
        dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
            if let imageData = imageData {
                cell.coverImageView.image = UIImage(data: imageData)
            }
        })
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
        
        let now = Date()
        if let time = activity.time {
            let timeStr = calculateTimeDiffInMins(now: now, activityTime: time)
            cell.setLabelImage(label: cell.countdownLabel, imageName: "clock", text: "Jio starts in \(timeStr)")
        } else {
            cell.setLabelImage(label: cell.countdownLabel, imageName: "clock", text: "Jio starts in the future")
        }
    }
    
    func calculateTimeDiffInMins(now: Date, activityTime: Date) -> String {
        let countdown = activityTime.timeIntervalSince(now)
        let hours = floor(countdown / 60 / 60)
        let minutes = floor((countdown - (hours * 60 * 60)) / 60)
        let timeStr = "\(Int(hours)) hours \(Int(minutes)) minutes"
        return timeStr
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        // return true if all items are editable
        // user should be able to quit
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteActivity(activityIndexPath: indexPath)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.Storyboard.viewActivityDetailSegue, sender: indexPath.row)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.viewActivityDetailSegue,
            let activityDetailController = segue.destination as? ActivityDetailViewController {
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedActivity = activities[indexPath.row]
            activityDetailController.activity = selectedActivity
            activityDetailController.activityIndexPath = indexPath
            activityDetailController.delegate = self
        }
    }

}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let nusjioImage = UIImage(named: "NUSJioLogoGrey20")
        let imageView = UIImageView(image: nusjioImage)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(imageView)
        
        // my attempt
        titleLabel.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 290).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        imageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: 30).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
    }
}

extension ActivityCell {
    func setLabelImage(label: UILabel, imageName: String, text: String) {
        // Create Attachment
        let imageAttachment = NSTextAttachment()
        let originalImage = UIImage(systemName: imageName)
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        tintedImage?.withTintColor(UIColor.secondaryLabel)
        imageAttachment.image = tintedImage
        // Set bound to reposition
        let imageOffsetY: CGFloat = -5.0
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        // Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        // Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        // Add image to mutable string
        completeText.append(attachmentString)
        // Add your text to mutable string
        let textAfterIcon = NSAttributedString(string: text)
        completeText.append(textAfterIcon)
        label.textAlignment = .left
        label.attributedText = completeText
    }
}

extension UIView {
    func showBlurLoader() {
        let blurLoader = BlurLoader(frame: frame)
        self.addSubview(blurLoader)
    }

    func removeBluerLoader() {
        if let blurLoader = subviews.first(where: { $0 is BlurLoader }) {
            blurLoader.removeFromSuperview()
        }
    }
}


class BlurLoader: UIView {

    var blurEffectView: UIVisualEffectView?

    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
}
