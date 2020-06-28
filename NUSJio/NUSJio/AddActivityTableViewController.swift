//
//  AddActivityTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddActivityTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var delegate: CustomTabBarDelegate?
    let dataController = DataController()
    var currentUser: User!
    var activity: Activity?
    var isEditEvent: Bool = false
    
    // MARK: UI
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeDatePicker: UIDatePicker!
    @IBOutlet var chosenLocationLabel: UILabel!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var uploadImageProgressView: UIProgressView!
    
    // description
    let descriptionTextViewIndexPath = IndexPath(row: 1, section: 0)
    
    // time and location section
    var isPickerHidden = true
    let timeLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    
    var isChosenLocationHidden = true {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    let chosenLocationLabelIndexPath = IndexPath(row: 3, section: 1)
    
    // cover image
    var isCoverImageHidden = true {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    let coverImageLabelIndexPath = IndexPath(row: 0, section: 3)
    let coverImageViewIndexPath = IndexPath(row: 2, section: 3)
    
    // progress view
    var isProgressViewHidden = true {
           didSet {
               tableView.beginUpdates()
               tableView.endUpdates()
           }
       }
    let progressViewIndexPath = IndexPath(row: 1, section: 3)
    
    let normalCellHeight: CGFloat = 44.0
    let largeCellHeight: CGFloat = 120.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
         uploadImageProgressView.progress = 0.0
        if let activity = activity {
            isEditEvent = true
            navigationItem.title = "Edit Activity"
            titleTextField.text = activity.title
            descriptionTextView.text = activity.description
            if let time = activity.time {
                 timeLabel.text = Activity.timeDateFormatter.string(from: time)
            } else {
                timeLabel.text = "No fixed time yet"
            }
            chosenLocationLabel.text = activity.location
            dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
                if let imageData = imageData {
                    self.coverImageView.image = UIImage(data: imageData)
                    self.isCoverImageHidden = false
                }
            })
        } else {
            updateSaveButtonState()
            timeDatePicker.date = Date().addingTimeInterval(60*30)
            updateTimeLabel(date: timeDatePicker.date)
        }
        
        // get current user
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                }
            }
        } else {
            print("oops no current user")
        }
        
    }
    
    // --- configure title text field ---
    
    // required fields: title
    // time, location have default value
    // should be called after each keyboard tap in the text field
    func updateSaveButtonState() {
        let title = titleTextField.text ?? ""
        saveButton.isEnabled = !title.isEmpty
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // need to save the data
        var uuid = ""
        if isEditEvent {
            uuid = activity!.uuid
        } else {
            uuid = UUID.init().uuidString
        }
        let title = titleTextField.text!
        let description = descriptionTextView.text
        let hostId = currentUser!.uuid
        let time = timeDatePicker.date
        let location = chosenLocationLabel.text!
        // let filters
        let coverImage = coverImageView.image
        
        // upload image
        var imageURLStr = ""
        isProgressViewHidden = false
        dataController.uploadImageAndGetURL(image: coverImage!, progressView: uploadImageProgressView) {(urlStr) in
            if let urlStr = urlStr {
                imageURLStr = urlStr
                print("\(imageURLStr)")
                self.activity = Activity(uuid: uuid, title: title, description: description, hostId: hostId, participantIds: nil, location: location, time: time, tags: nil, isComplete: false, imageURLStr:imageURLStr)
                
                self.dataController.saveActivity(activity: self.activity!)
                self.delegate?.goTo(index: 0, activity: self.activity!)
                self.navigationController?.dismiss(animated: true, completion: {
                    print("dismiss \(self.navigationController!.viewControllers)")
                })
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // will fire whenever the Editing Changed control event takes place
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // take place when user hit "Return"
    @IBAction func returnPressed(_ sender: UITextField) {
        titleTextField.resignFirstResponder()
    }
    
    // --- configure date label ---
    func updateTimeLabel(date: Date) {
        timeLabel.text = Activity.timeDateFormatter.string(from: date)
    }
    
    // fire whenever the user changes the date picker
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateTimeLabel(date: timeDatePicker.date)
    }
    
    // TO DO
    // --- configure location picker ---
    // need to set is location hidden to false here
    @IBAction func unwindToAddActivity(segue: UIStoryboardSegue) {
        // unwind from location page
        let location = chosenLocationLabel.text ?? ""
        isChosenLocationHidden = location.isEmpty
    }
    
    // --- configure image picker ---
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)})
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler:  { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.popoverPresentationController?.sourceView = sender
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
           guard let selectedImage = info[.originalImage] as? UIImage else { return }
           
           coverImageView.image = selectedImage
        print("did finish picking \(isCoverImageHidden)")
        isCoverImageHidden = false
        // need to save image here
           dismiss(animated: true, completion: nil)
    }
    
    // --- configure date picker, description and image picker ---
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath:
            return isPickerHidden ? 0 : timeDatePicker.frame.height
            
        case descriptionTextViewIndexPath:
            return largeCellHeight
            
        case chosenLocationLabelIndexPath:
            return isChosenLocationHidden ? 0 : normalCellHeight
            
        case progressViewIndexPath:
            return isProgressViewHidden ? 0 : normalCellHeight
            
        case coverImageViewIndexPath:
            return isCoverImageHidden ? 0 : coverImageView.frame.height
            
        default:
            return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == timeLabelIndexPath {
            isPickerHidden = !isPickerHidden
            if isPickerHidden {
                timeLabel.textColor = .black
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
