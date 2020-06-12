//
//  ActivityDetailViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/11.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {

    var activity: Activity?
    
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
        
        setUpElements()
    }
    
    func setUpElements() {
        coverImageView.image = activity?.coverPicture
        titleLabel.text = activity?.title
        timeLabel.text = Activity.timeDateFormatter.string(for: activity?.time)
        // tagLabel.text =
        descriptionTextView.text = activity?.description
    }
    
    @IBAction func unwindToActivityDetail(segue: UIStoryboardSegue) {
        guard segue.identifier == Constants.Storyboard.saveUnwindToActivityDetail else {return}
        let sourceViewController = segue.source as! ActivityDetailViewController
        if let activity = sourceViewController.activity {
            sourceViewController.activity = activity
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
