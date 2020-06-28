//
//  ActivityDetailViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/11.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

protocol ActivityDetailDelegate: class {
    func deleteActivity(activityIndexPath: IndexPath)
}

class ActivityDetailViewController: UIViewController {

    let dataController = DataController()
    
    var activity: Activity!
    var activityIndexPath: IndexPath?
    var isDeleteAction = false
    var isEditAction = false
    var isCreateAction = false
    
    weak var delegate: ActivityDetailDelegate?
    weak var tabBarDelegate: CustomTabBarDelegate?
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var startJioButton: UIButton!
    @IBOutlet var viewChatButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI() {
        dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
            if let imageData = imageData {
                self.coverImageView.image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    // coverImageView.image = activity.coverPicture
                    self.titleLabel.text = self.activity.title
                    self.timeLabel.text = Activity.timeDateFormatter.string(for: self.activity.time)
                    self.locationLabel.text = self.activity.location
                    // tagLabel.text =
                    self.descriptionTextView.text = self.activity.description
                }
            }
        })
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.editActivitySegue, let navController = segue.destination as? UINavigationController,
            let addActivityTableViewController = navController.topViewController as?
                AddActivityTableViewController {
            addActivityTableViewController.activity = activity
            
            // assign delegate, so delegate not nil???
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(identifier: "CustomTabBarController") as! CustomTabBarDelegate
            addActivityTableViewController.delegate = tabBarVC
            print("(print from activity detail) prepare \(addActivityTableViewController.delegate)")
            
        }
    }

}
