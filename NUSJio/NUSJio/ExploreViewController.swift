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


class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var SearchField: UITextField!
    @IBOutlet var listOfActivities: UITableView!
    
    //examples:
    // var examples = Activity.loadSampleActivities();
    var allActivities : [Activity] = [];
    let dataController = DataController()
    
    override func viewWillAppear(_ animated: Bool) {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listOfActivities.delegate = self;
        // check whether the datasource should be self
        listOfActivities.dataSource = self;
        
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
        return self.allActivities.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listOfActivities.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        
//        cell.textLabel?.text = self.allActivities[indexPath.row].title;
//        cell.detailTextLabel?.text = self.allActivities[indexPath.row].description;
//        if (self.allActivities[indexPath.row].coverPicture != nil) {
//            cell.imageView?.image = self.allActivities[indexPath.row].coverPicture;
//        } else {
//            //TODO: add default image
//            cell.imageView?.image = nil;
//        }
        
        let activity = allActivities[indexPath.row]
        updateCellUI(cell: cell, activity: activity)
        
        return cell;
    }
    
    func updateCellUI(cell: UITableViewCell, activity: Activity) {
        // cell.layer.cornerRadius = 6
        dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
            if let imageData = imageData {
//                cell.coverImageView.image = UIImage(data: imageData)
                print("imageData is fetched")
            }
        })
        cell.textLabel?.text = activity.title
        cell.detailTextLabel?.text = activity.description;
    }
    
    
//    func userByID(ID: String) -> User {
//        let database = Firestore.firestore();
//        var userName: String = "No Name Yet";
//        var user: User = User(username: "No Name Yet");
//
//        database.collection("users").document("user-" + ID).getDocument { (doc, error) in
//            if error == nil {
//                if doc != nil && doc!.exists {
//                    userName = doc!.get("username") as! String
//                    user = User(username: userName);
//                }
//            }
//        }
//
//        return user;
//    }
    
    @IBAction func searchFieldTyped(_ sender: Any) {
//        var text = SearchField.text;
//        var database = Firestore.firestore();
//        var filteredActivities : [Activity] = [];
//
//        database.collection("activities").whereField("title", arrayContains: text ?? "").getDocuments{ (snapshot, error) in
//            if (error == nil && snapshot != nil) {
//                for activity in snapshot!.documents {
//
//                    var participants = [User]()
//                    for id in activity.get("participantIds") as! [String] {
//                        participants.append(self.userByID(ID: id));
//                    }
//
//
//                    let url = URL(string:activity.get("imageURLStr") as! String)
//                    let data = try! Data(contentsOf: url!);
//                    let image = UIImage(data: data)!;
//
//
//                    let timestamp = activity.get("time") as! Timestamp;
//    //TODO: format time
//                    var time = Activity.timeDateFormatter.date(from: "2020/11/11 11:11")!
//
//                    let currentActivity = Activity.init(
//                        title: activity.get("title") as! String  ,
//                        description:activity.get("description") as! String,
//                        host: self.userByID(ID: activity.get("hostId") as! String),
//                        participants: participants,
//                        location: activity.get("location") as! String,
//                        time: time,
//                        tags: activity.get("tags") as! [String],
//                        isComplete: activity.get("isComplete") as! Bool,
//                        coverPicture: image)
//                    filteredActivities.append(currentActivity);
//                }
//            }
//        }
    }
}

