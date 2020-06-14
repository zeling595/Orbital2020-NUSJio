//
//  MyActivitiesTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

protocol ActivityDetailDelegate: class {
    func passEditedActivity(editedActivity: Activity, activityIndexPath: IndexPath)
}

class MyActivitiesTableViewController: UITableViewController, ActivityDetailDelegate {

    // TODO: Implement this using priority queue
    var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Storyboard.activityCellIdentifier)
        
        if let savedActivities = Activity.loadActivities() {
            activities = savedActivities
        } else {
            activities = Activity.loadSampleActivities()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func passEditedActivity(editedActivity: Activity, activityIndexPath: IndexPath) {
        print("\(editedActivity)")
        activities[activityIndexPath.row] = editedActivity
        tableView.reloadRows(at: [activityIndexPath], with: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // learn how to do 2 sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.activityCellIdentifier, for: indexPath) as? ActivityCell else {
            fatalError("Could not dequeue a cell")
        }

        // Configure the cell...
        let activity = activities[indexPath.row]
        updateCellUI(cell: cell, activity: activity)

        return cell
    }
    
    func updateCellUI(cell: ActivityCell, activity: Activity) {
        cell.imageView?.image = activity.coverPicture
        cell.titleLabel.text = activity.title
        cell.timeLabel.text = Activity.timeDateFormatter.string(from: activity.time)
        // cell.tagsLabel = activity.tags
        let participantCount = 0
        let countStr = String(participantCount)
        cell.participantsLabel.text = "Number of participants is \(countStr)"
        let now = Date()
        let timeStr = calculateTimeDiffInMins(now: now, activityTime: activity.time)
        cell.countdownLabel.text = "Jio starts in \(timeStr)"
        
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
            // Delete the row from the data source
            activities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.Storyboard.viewActivityDetailSegue, sender: indexPath.row)
    }
    
    @IBAction func unwindToMyActivities(segue: UIStoryboardSegue) {
        guard segue.identifier == Constants.Storyboard.saveUnwindToMyActivities else {return}
        let sourceViewController = segue.source as! AddActivityTableViewController
        if let activity = sourceViewController.activity {
            let newIndexPath = IndexPath(row: activities.count, section: 0)
            activities.append(activity)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
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
