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
    
    var activities: [[Activity]] = []
    var currentUser: User!
    let dataController = DataController()
    var toolbar: UIToolbar?
    var datePicker: UIDatePicker?
    
    
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
                    self.dataController.fetchUserActivitiesSectioned(user: self.currentUser) { (fetchedActivities) in
                        if let fetchedActivities = fetchedActivities, !fetchedActivities.isEmpty {
                            self.activities = fetchedActivities
                            // print(fetchedActivities)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        DispatchQueue.main.async {
                            self.view.removeBluerLoader()
                        }
                        
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
        
        // navigationItem.leftBarButtonItem = editButtonItem
        
        // self-sizing
        tableView.estimatedRowHeight = 350
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func deleteActivity(activityIndexPath: IndexPath) {
        dataController.deleteActivity(activityToBeDeleted: activities[activityIndexPath.section][activityIndexPath.row])
        activities[activityIndexPath.section].remove(at: activityIndexPath.row)
        tableView.deleteRows(at: [activityIndexPath], with: .fade)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        let label = UILabel()
        label.frame = CGRect(x: 16, y: 10, width: headerView.frame.width - 32, height: headerView.frame.height - 10)
        label.textColor = Styles.themeOrange
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
        label.layer.masksToBounds = true
        if section == 0 {
            label.text = " Today"
        } else {
            label.text = " Upcoming"
        }
        headerView.addSubview(label)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if activities[0].count == 0 && activities[1].count == 0 {
            return 0
        }
        return 50
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activities[0].count == 0 && activities[1].count == 0 {
            tableView.setEmptyView(title: "Create your own or explore more activities", message: "You activities will be here")
        } else {
            tableView.restore()
        }
        // return activities.count
        return activities[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.activityCellIdentifier, for: indexPath) as? ActivityCell else {
            fatalError("Could not dequeue a cell")
        }

        // Configure the cell...
        cell.delegate = self
        cell.tagsCollectionView.isUserInteractionEnabled = false
        // let activity = activities[indexPath.row]
        let activity = activities[indexPath.section][indexPath.row]
        // print(activity)
        cell.tags = Activity.getTagsArray(activity: activity)
        cell.tagsCollectionView.reloadData()
        cell.tagsCollectionView.layoutIfNeeded()
        updateCellUI(cell: cell, activity: activity)

        return cell
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
    
    // MARK: UI
    func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(Styles.themeOrange, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func updateCellUI(cell: ActivityCell, activity: Activity) {
        cell.mainView.layer.cornerRadius = CGFloat(Constants.cellCornerRadius)
        cell.mainView.layer.masksToBounds = true
        
        // remove the button first
        cell.buttonStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        if activity.hostId == currentUser.uuid {
            // host activity, display postpone and stop looking for new people button
            let postponeButton = createButton(title: "Postpone")
            postponeButton.addTarget(cell, action: #selector(ActivityCell.postponeButtonTapped), for: .touchUpInside)
            cell.postponeButton = postponeButton
            
            var secondButton: UIButton
            if activity.state == .open {
                // jio button
                let jioButton = createButton(title: "Jio")
                jioButton.addTarget(cell, action: #selector(ActivityCell.jioButtonTapped), for: .touchUpInside)
                cell.jioButton = jioButton
                secondButton = jioButton
            } else {
                // state == close, complete button
                let completeButton = createButton(title: "Complete")
                completeButton.addTarget(cell, action: #selector(ActivityCell.completeButtonTapped), for: .touchUpInside)
                cell.completeButton = completeButton
                secondButton = completeButton
                let calender = Calendar.current
                if calender.isDateInToday(activity.time!) {
                    completeButton.isEnabled = true
                } else {
                    completeButton.isEnabled = false
                    completeButton.setTitleColor(UIColor.gray, for: .disabled)
                }
            }
            
            cell.buttonStackView.alignment = .fill
            cell.buttonStackView.distribution = .fillEqually
            cell.buttonStackView.spacing = 8.0
            
            cell.buttonStackView.addArrangedSubview(postponeButton)
            cell.buttonStackView.addArrangedSubview(secondButton)
        } else {
            // joined activity, maybe can quit??
            let viewButton = createButton(title: "View")
            viewButton.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
            cell.viewButton = viewButton
            
            cell.buttonStackView.alignment = .fill
            cell.buttonStackView.distribution = .fillEqually
            cell.buttonStackView.spacing = 8.0
            
            cell.buttonStackView.addArrangedSubview(viewButton)
        }
        
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
            let calender = Calendar.current
            if calender.isDateInToday(time) {
                let timeStr = calculateTimeDiffInMins(now: now, activityTime: time)
                cell.setLabelImage(label: cell.countdownLabel, imageName: "clock", text: " Jio starts in \(timeStr)")
            } else {
                cell.setLabelImage(label: cell.countdownLabel, imageName: "clock", text: " Jio starts soon")
            }
        } else {
            // not really possible, all activity has time
            cell.setLabelImage(label: cell.countdownLabel, imageName: "clock", text: " Jio starts in the future")
        }
    }
    
    func calculateTimeDiffInMins(now: Date, activityTime: Date) -> String {
        let countdown = activityTime.timeIntervalSince(now)
        let hours = floor(countdown / 60 / 60)
        let minutes = floor((countdown - (hours * 60 * 60)) / 60)
        let timeStr = "\(Int(hours)) hours \(Int(minutes)) minutes"
        return timeStr
    }
    
    
    // MARK: Button method
    func postponeButtonTapped(cell: ActivityCell) {
        // maybe need to assign self.date picker to it
        let datePicker = UIDatePicker()
        let heightForDatePicker: CGFloat = 300
        datePicker.backgroundColor = UIColor.white
        datePicker.setValue(0.95, forKey: "alpha")

        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - heightForDatePicker, width: UIScreen.main.bounds.size.width, height: heightForDatePicker)
        self.datePicker = datePicker
        self.view.addSubview(datePicker)

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - heightForDatePicker, width: UIScreen.main.bounds.size.width, height: 60))
        toolbar.barStyle = .default
        // toolbar.isTranslucent = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        cancelButton.tintColor = Styles.themeOrange
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: cell, action: #selector(ActivityCell.doneButtonTapped))
        doneButton.tintColor = Styles.themeOrange
        toolbar.items = [cancelButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        toolbar.sizeToFit()
        self.toolbar = toolbar
        self.view.addSubview(toolbar)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none

        if let date = sender?.date {
            print("Picked the date \(dateFormatter.string(from: date))")
        }
    }
    
    @objc func cancelButtonTapped() {
        toolbar!.removeFromSuperview()
        datePicker!.removeFromSuperview()
    }
    
    @objc func doneButtonTapped(cell: ActivityCell) {
        toolbar!.removeFromSuperview()
        datePicker!.removeFromSuperview()
        // update the activity
        guard let timeInterval = datePicker?.countDownDuration else {return}
        
        // front end
        guard let indexPath = self.tableView.indexPath(for: cell) else {return}
        let selectedActivity = activities[indexPath.section][indexPath.row]
        let newDate = selectedActivity.time!.addingTimeInterval(timeInterval)
        cell.timeLabel.text = Activity.timeDateFormatter.string(from: newDate)
        let newActivity = Activity(
            uuid: selectedActivity.uuid,
            title: selectedActivity.title,
            description: selectedActivity.description,
            hostId: selectedActivity.hostId,
            participantIds: selectedActivity.participantIds,
            participantsInfo: selectedActivity.participantsInfo,
            likedBy: selectedActivity.likedBy,
            location: selectedActivity.location,
            time: newDate,
            state: selectedActivity.state,
            imageURLStr: selectedActivity.imageURLStr,
            categories: selectedActivity.categories,
            numOfParticipants: selectedActivity.numOfParticipants,
            gender: selectedActivity.gender,
            faculties: selectedActivity.faculties,
            selectedFacultiesBoolArray: selectedActivity.selectedFacultiesBoolArray)
        self.activities[indexPath.section][indexPath.row] = newActivity
        // backend
        dataController.postponeActivity(activity: selectedActivity, newDate: newDate)
    }
    
    // other user cannot join
    // disappear from search
    // do not allow user to change alr formed jio??
    func jioButtonTapped(cell: ActivityCell) {
        // display an alert
        let title = "Finalise Jio"
        let msg = "This action will remove your Jio from \"Explore Tab\". Press \"OK\" once you decide to stop looking for new participants."
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // change state from open to close
            // back end
            guard let indexPath = self.tableView.indexPath(for: cell) else {return}
            let selectedActivity = self.activities[indexPath.section][indexPath.row]
            self.dataController.changeActivityState(activity: selectedActivity, changeTo: .closed)
            // front end
            let newActivity = Activity(
                uuid: selectedActivity.uuid,
                title: selectedActivity.title,
                description: selectedActivity.description,
                hostId: selectedActivity.hostId,
                participantIds: selectedActivity.participantIds,
                participantsInfo: selectedActivity.participantsInfo,
                likedBy: selectedActivity.likedBy,
                location: selectedActivity.location,
                time: selectedActivity.time,
                state: .closed,
                imageURLStr: selectedActivity.imageURLStr,
                categories: selectedActivity.categories,
                numOfParticipants: selectedActivity.numOfParticipants,
                gender: selectedActivity.gender,
                faculties: selectedActivity.faculties,
                selectedFacultiesBoolArray: selectedActivity.selectedFacultiesBoolArray)
            self.activities[indexPath.section][indexPath.row] = newActivity
            // change jio button to complete button, preferrably with animation
            let completeButton = self.createButton(title: "Complete")
            completeButton.addTarget(cell, action: #selector(ActivityCell.completeButtonTapped), for: .touchUpInside)
            cell.completeButton = completeButton
            // remove jio button, add complete button
            cell.buttonStackView.removeArrangedSubview(cell.jioButton!)
            cell.jioButton?.removeFromSuperview()
            cell.buttonStackView.addArrangedSubview(completeButton)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func completeButtonTapped(cell: ActivityCell) {
        // display an alert
        let title = "Complete Jio"
        let msg = "This action will remove your Jio from \"Explore Tab\" and \"My Activities Tab\". Press \"OK\" to complete a Jio."
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // change state from closed to completed
            guard let indexPath = self.tableView.indexPath(for: cell) else {return}
            let selectedActivity = self.activities[indexPath.section][indexPath.row]
            // back end
            self.dataController.changeActivityState(activity: selectedActivity, changeTo: .completed)
            // remove it from my activities, but not from database
            self.activities[indexPath.section].remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            // TODO: transition to leave a comment page?
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // not necessary now
    @objc func viewButtonTapped(sender: UIButton!) {
        
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.viewActivityDetailSegue,
            let activityDetailController = segue.destination as? ActivityDetailViewController {
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedActivity = activities[indexPath.section][indexPath.row]
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
