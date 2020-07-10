//
//  ActivityDetailViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/11.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

protocol ActivityDetailDelegate: class {
    func deleteActivity(activityIndexPath: IndexPath)
}

class ActivityDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let dataController = DataController()
    
    var activity: Activity!
    var activityIndexPath: IndexPath?
    var isDeleteAction = false
    var isEditAction = false
    var isCreateAction = false
    
    var tags: [String] {
        return Activity.getTagsArray(activity: activity)
    }
    
    weak var delegate: ActivityDetailDelegate?
    weak var tabBarDelegate: CustomTabBarDelegate?
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var tagsCollectionView: UICollectionView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var startJioButton: UIButton!
    @IBOutlet var viewChatButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    
    override func viewDidLoad() {
        updateUI()
        super.viewDidLoad()
        
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
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
        dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
            if let imageData = imageData {
                self.coverImageView.image = UIImage(data: imageData)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = tags[indexPath.item]
        cell.tagLabel.textColor = UIColor.white
        return cell
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
