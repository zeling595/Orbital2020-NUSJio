//
//  ExploreViewController.swift
//  NUSJio
//
//  Created by 程及雨晴 on 28/6/20.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import Firebase
import Foundation


class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet var listOfActivities: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    //examples:
    var examples = Activity.loadSampleActivities();
    var allActivities : [Activity] = [];
    var filteredActivities: [Activity] = [];
    let dataController = DataController()
    var filtered = false;
    
    override func viewWillAppear(_ animated: Bool) {
        filtered = false;
        dataController.fetchAllActivities { (activities) in
            if let activities = activities {
                print(activities)
                self.allActivities = activities
                self.listOfActivities.reloadData()
            } else {
                print("error fetching all activities")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filtered = false;
        filteredActivities = [];
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        filtered = false;
        listOfActivities.delegate = self;
        listOfActivities.dataSource = self;
        searchBar.delegate = self;
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if segue.identifier == "ExploreToDetailSegue",
                let exploreDetailController = segue.destination as? ExploreDetailViewController {
                let indexPath = listOfActivities.indexPathForSelectedRow!
                let selectedActivity = allActivities[indexPath.row]
                exploreDetailController.activity = selectedActivity
                exploreDetailController.activityIndexPath = indexPath
            }
    
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // direct to detail
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allActivities.count)
        guard filtered == true else {
            return self.allActivities.count;
        }
        
        return filteredActivities.count;
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listOfActivities.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        

        if filteredActivities.isEmpty {
            
            let activity = allActivities[indexPath.row]
            updateCellUI(cell: cell, activity: activity)
            return cell;
            
        } else {
            let activity = filteredActivities[indexPath.row]
            updateCellUI(cell: cell, activity: activity)
            return cell;
        }
        
    }
    
    
    //TODO: make image not compulsory
    func updateCellUI(cell: UITableViewCell, activity: Activity) {
        // cell.layer.cornerRadius = 6
        dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
            if let imageData = imageData {
                cell.imageView!.image = UIImage(data: imageData)
                print("imageData is fetched")
            }
        })
        cell.textLabel?.text = activity.title
        cell.detailTextLabel?.text = activity.description;
    }
    
    
    func filterActivity (_ query: String?) {
        filteredActivities = [];
        guard let query = query else {return}
        print("searching")
        let text = query.lowercased();
        for activity in allActivities {
                let title = activity.title.lowercased()
                let location = activity.location
                let tags = activity.tags
                let description = activity.description
                //the real search part:
            
                if title.contains(text) {
                    filteredActivities.append(activity);
                } else if description != nil && description!.lowercased().contains(text) {
                    filteredActivities.append(activity);
                } else if tags != nil && tags!.contains(text) {
                    //TODO: make tags lowercase
                    filteredActivities.append(activity);
                } else if location != nil && location!.lowercased().contains(text) {
                    filteredActivities.append(activity);
                }
                    
            filtered = true;
            self.listOfActivities.reloadData();
            
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filterActivity(searchText);
        } else {
            filteredActivities = []
            filtered = false;
        }
        self.listOfActivities.reloadData();
    }
    
    
}

