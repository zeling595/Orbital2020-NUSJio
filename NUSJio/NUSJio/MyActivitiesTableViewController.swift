//
//  MyActivitiesTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class MyActivitiesTableViewController: UITableViewController {

    // TODO: Implement this using priority queue
    var activities = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Storyboard.activityCellIdentifier)
        
        if let savedActivities = Activity.loadActivities() {
            activities = savedActivities
        } else {
            activities = Activity.loadSampleActivities()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.activityCellIdentifier, for: indexPath)

        // Configure the cell...
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.title

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
        }
    }

}
