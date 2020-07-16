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
    
    class OrderedActivity{
        var activity: Activity;
        var priority: Int;
        
        init (activity: Activity) {
            self.activity = activity;
            priority = 0;
        }
        
        func incrementPriority() {
            self.priority = self.priority + 1;
        }
        
        func decrementPriority() {
            self.priority = self.priority - 1;
        }
    }
    
    @IBOutlet var listOfActivities: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    //examples:
    var examples = Activity.loadSampleActivities();
    var allActivities : [Activity] = [];
    var filteredActivities: [Activity] = [];
    let dataController = DataController()
    var filtered = false;
    
    override func viewWillAppear(_ animated: Bool) {
        if !searchBar.text!.isEmpty  {
            filtered = true;
            filterActivity(searchBar.text);
        } else {
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
            var selectedActivity : Activity;
            if filtered {
                selectedActivity = filteredActivities[indexPath.row]
            } else {
                selectedActivity = allActivities[indexPath.row]
            }
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
                //print("imageData is fetched")
            }
        })
        cell.textLabel?.text = activity.title
        cell.detailTextLabel?.text = activity.description;
    }
    
    func compare(a1: OrderedActivity, a2: OrderedActivity) -> Bool{
        if a1.priority >= a2.priority {
            return true;
        } else {
            return false;
        }
    }
    
    
    func filterActivity (_ query: String?) {
        filteredActivities = [];
        guard let query = query else {return}
        print("searching")
        let text = query.lowercased();
        let splitedText = text.components(separatedBy: " ");
        var sortedActivity: [OrderedActivity] = [];
        
        var prefixedText : [String] = [];
        var suffixedText : [String] = [];
        for text in splitedText {
            prefixedText.append(String(text.prefix(3)))
            suffixedText.append(String(text.suffix(3)))
        }
        print (prefixedText)
        print (suffixedText)
        
        for activity in allActivities {
            var wrappedActivity = OrderedActivity(activity: activity);
                let title = activity.title.lowercased()
            let location = activity.location?.lowercased()
                let tags = activity.tags
            let description = activity.description?.lowercased()
                //the real search part:
            
            
            
            //looping through splited text (i.e. all seperated words)
            for i in 0...splitedText.count-1 {
                //if one/some of the words are contained
                let word = splitedText[i];
                if title.contains(word) {
                    sortedActivity.append(wrappedActivity);
                } else if description != nil && description!.lowercased().contains(word) {
                    sortedActivity.append(wrappedActivity);
                } else if tags != nil && tags!.contains(word) {
                    //TODO: make tags lowercase
                    sortedActivity.append(wrappedActivity);
                } else if location != nil && location!.lowercased().contains(word) {
                    //sortedActivity.append(wrappedActivity);
                } else {
                    wrappedActivity.decrementPriority();
                }
            }
            //to search prefix/suffix
            for j in 0...splitedText.count-1 {
                let word1 = prefixedText[j]
                let word2 = suffixedText[j]
                if title.contains(word1) || title.contains(word2){
                    sortedActivity.append(wrappedActivity);
                } else if description != nil && (description!.lowercased().contains(word1) || description!.lowercased().contains(word2)) {
                    sortedActivity.append(wrappedActivity);
                } else if tags != nil && (tags!.contains(word1) || tags!.contains(word2)) {
                    //TODO: make tags lowercase
                    sortedActivity.append(wrappedActivity);
                } else if location != nil && (location!.lowercased().contains(word1) || location!.lowercased().contains(word2)) {
                    //sortedActivity.append(wrappedActivity);
                } else {
                    wrappedActivity.decrementPriority();
                }
            }
            
            sortedActivity.sort(by: compare)
            for activity in sortedActivity {
                filteredActivities.append(activity.activity);
            }
            /*
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
             */
                
                    
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

