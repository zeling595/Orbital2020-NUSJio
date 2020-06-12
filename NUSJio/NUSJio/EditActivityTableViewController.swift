//
//  EditActivityTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/11.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class EditActivityTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var activity: Activity?
    
    // IB outlets, location has not implemented
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeDatePicker: UIDatePicker!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var coverImageView: UIImageView!
    
    var isPickerHidden = true
    let timeLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let descriptionTextViewIndexPath = IndexPath(row: 1, section: 0)
    var isCoverImageHidden = true {
       didSet{
           tableView.beginUpdates()
           tableView.endUpdates()
        }
    }
    let coverImageLabelIndexPath = IndexPath(row: 0, section: 3)
    let coverImageViewIndexPath = IndexPath(row: 1, section: 3)
    
    let normalCellHeight: CGFloat = 44.0
    let largeCellHeight: CGFloat = 120.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        updateSaveButtonState()
//        timeDatePicker.date = Date()
//        updateTimeLabel(date: timeDatePicker.date)
    }
    
    func setUpElements() {
        titleTextField.text = activity?.title
        descriptionTextView.text = activity?.description
        timeLabel.text = Activity.timeDateFormatter.string(from: activity!.time)
        coverImageView.image = activity?.coverPicture
    }

   // --- configure title text field ---
   
   // required fields: title
   // time, location have default value
   // should be called after each keyboard tap in the text field
   func updateSaveButtonState() {
       let title = titleTextField.text ?? ""
       saveButton.isEnabled = !title.isEmpty
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
    
    // TODO
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
    
    // TODO
    // --- configure location picker ---
    
       
    // --- configure date picker, description and image picker ---
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           switch indexPath {
           case datePickerIndexPath:
               return isPickerHidden ? 0 : timeDatePicker.frame.height
               
           case descriptionTextViewIndexPath:
               return largeCellHeight
               
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard segue.identifier == Constants.Storyboard.saveUnwindToActivityDetail else {return}
               
        let title = titleTextField.text!
        let description = descriptionTextView.text
        let time = timeDatePicker.date
        // let location
        // let filters
        let coverImage = coverImageView.image
       
        activity = Activity(title: title, description: description, host: nil, participants: nil, location: nil, time: time, tags: nil, isComplete: false, coverPicture: coverImage)
    }

}
