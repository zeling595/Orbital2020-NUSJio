//
//  ExploreDetailViewController.swift
//  NUSJio
//
//  Created by 程及雨晴 on 29/6/20.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class ExploreDetailViewController: UIViewController {

    var activity: Activity!
    var activityIndexPath: IndexPath!
    // var isEdited: Bool = false
    weak var delegate: ActivityDetailDelegate?
    let dataController = DataController()
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var chatWithHostButton: UIButton!

    
    
    override func viewDidLoad() {
        updateUI()
        super.viewDidLoad()
    }
    

    
    func updateUI() {
        dataController.fetchImage(imageURL: activity.imageURLStr) { (data) in
            if let data = data {
                let image = UIImage(data: data)
                self.coverImageView.image = image
            }
        }
        titleLabel.text = activity.title
        timeLabel.text = Activity.timeDateFormatter.string(for: activity.time)
        // tagLabel.text =
        descriptionTextView.text = activity.description
    }
    
    @IBAction func unwindToExplore(segue: UIStoryboardSegue) {
       
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
