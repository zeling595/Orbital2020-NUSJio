//
//  ActivityDetailViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/11.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {

    var activity: Activity!
    var activityIndexPath: IndexPath!
    // var isEdited: Bool = false
    weak var delegate: ActivityDetailDelegate?
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var startJioButton: UIButton!
    @IBOutlet var viewChatButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        print("will move to parent")
        delegate?.passEditedActivity(editedActivity: activity, activityIndexPath: activityIndexPath)
    }
    
    func updateUI() {
        coverImageView.image = activity.coverPicture
        titleLabel.text = activity.title
        timeLabel.text = Activity.timeDateFormatter.string(for: activity.time)
        // tagLabel.text =
        descriptionTextView.text = activity.description
    }
    
    @IBAction func unwindToActivityDetail(segue: UIStoryboardSegue) {
        guard segue.identifier == Constants.Storyboard.saveUnwindToActivityDetail else {return}
        let sourceViewController = segue.source as! EditActivityTableViewController
        if let activity = sourceViewController.activity {
            self.activity = activity
            updateUI()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.editActivitySegue, let navController = segue.destination as? UINavigationController,
            let editActivityTableViewController = navController.topViewController as?
                EditActivityTableViewController {
            editActivityTableViewController.activity = activity
        }
    }

}
