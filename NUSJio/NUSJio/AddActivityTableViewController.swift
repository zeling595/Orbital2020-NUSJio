//
//  AddActivityTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth
import AlignedCollectionViewFlowLayout

class AddActivityTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var delegate: CustomTabBarDelegate?
    let dataController = DataController()
    var currentUser: User!
    var activity: Activity?
    var tags: [String] = []
    var filter: Filter? // filter is an intermediate model object
    var isEditEvent: Bool = false
    
    // MARK: UI
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeDatePicker: UIDatePicker!
    @IBOutlet var chosenLocationLabel: UILabel!
    @IBOutlet var filtersCollectionView: UICollectionView! // newly added
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
    
    // filters
    var isFiltersCollectionViewHidden = true {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    let filtersCollectionViewIndexPath = IndexPath(row: 1, section: 2)
    
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
    
    func syncReloadData(_ collectionView: UICollectionView, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable self-sizing cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self
        let alignedFlowLayout = filtersCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        
        uploadImageProgressView.progress = 0.0
        timeDatePicker.minimumDate = Date()
        cameraButton.tintColor = Styles.themeOrange
        
        if let activity = activity {
            // from edit
            filter = Activity.getFilter(activity: activity)
            tags = Activity.getTagsArray(activity: activity)
            // TODO turn extract filter from activity
            
            isFiltersCollectionViewHidden = false
            isEditEvent = true
            navigationItem.title = "Edit Activity"
            titleTextField.text = activity.title
            descriptionTextView.text = activity.description
            if let time = activity.time {
                timeLabel.text = Activity.timeDateFormatter.string(from: time)
                timeDatePicker.date = time
            } else {
                timeLabel.text = "No fixed time yet"
            }
            isChosenLocationHidden = false
            chosenLocationLabel.text = activity.location
            dataController.fetchImage(imageURL: activity.imageURLStr, completion: { (imageData) in
                if let imageData = imageData {
                    self.coverImageView.image = UIImage(data: imageData)
                    self.isCoverImageHidden = false
                }
            })
        } else {
            if let filter = filter {
                // from filter
            } else {
                // from plus
                updateSaveButtonState()
                timeDatePicker.date = Date().addingTimeInterval(60*30)
                updateTimeLabel(date: timeDatePicker.date)
            }
        }
        
        // magic line to make the cell self-sizing
        if let collectionViewLayout = filtersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
    
    // MARK: Tags collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        // TODO: when there is no tag, show no tag is chosen, or hide the row
        cell.tagLabel.text = tags[indexPath.item]
        cell.tagLabel.textColor = UIColor.white
        
        return cell
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
        var participantIds: [String]
        var participantsInfo: [String: String]
        var likedBy: [String]
        var state: ActivityState
        if isEditEvent {
            uuid = activity!.uuid
            participantIds = activity!.participantIds
            participantsInfo = activity!.participantsInfo
            likedBy = activity!.likedBy
            state = activity!.state
            // print(state)
        } else {
            uuid = UUID.init().uuidString
            participantIds = []
            participantsInfo = [:]
            likedBy = []
            state = .open
        }
        let title = titleTextField.text!
        let description = descriptionTextView.text
        let hostId = currentUser!.uuid
        let time = timeDatePicker.date
        let location = chosenLocationLabel.text!
        let coverImage = coverImageView.image

        // tags, unpack from filter object
        var unpackedCategories: [String]?
        var unpackedNumOfParticipants: Int?
        var unpackedGender: Gender?
        var unpackedFaculties: [String]?
        var unpackedSelectedFacultiesBoolArray = Array(repeating: false, count: Constants.numOfFaculties)
        
        // print("\(filter)")
        
        if let filter = filter {
            if let categories = filter.categories {
                unpackedCategories = categories
            } else {
                unpackedCategories = nil
            }
            
            if let numOfParticipants = filter.numOfParticipants {
                unpackedNumOfParticipants = numOfParticipants
            } else {
                unpackedNumOfParticipants = nil
            }
            
            if let gender = filter.gender {
                unpackedGender = gender
            } else {
                unpackedGender = nil
            }
            
            if let faculties = filter.faculties {
                unpackedFaculties = faculties
            } else {
                unpackedFaculties = nil
            }
            unpackedSelectedFacultiesBoolArray = filter.selectedFacultiesBoolArray
        }
        
        // resize image
        let resizedImage = coverImage!.resized(toWidth: 374)
        
        // upload image
        // TODO: fix image can be optional
        var imageURLStr = ""
        isProgressViewHidden = false
        dataController.uploadImageAndGetURL(image: resizedImage!, progressView: uploadImageProgressView) {(urlStr) in
            if let urlStr = urlStr {
                imageURLStr = urlStr
                print("\(imageURLStr)")
            
                self.activity = Activity(uuid: uuid, title: title, description: description, hostId: hostId, participantIds: participantIds, participantsInfo: participantsInfo, likedBy: likedBy, location: location, time: time, state: state, imageURLStr: imageURLStr, categories: unpackedCategories, numOfParticipants: unpackedNumOfParticipants, gender: unpackedGender, faculties: unpackedFaculties, selectedFacultiesBoolArray: unpackedSelectedFacultiesBoolArray)
                
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
        switch segue.identifier {
        case "saveFromFilterToAddActivity":
            // from filters
            // print("saveFromFilterToAddActivity")
            self.tags = Filter.filterToTags(filter: self.filter!)
            // cannot be empty, must check before save
            syncReloadData(filtersCollectionView) {
                self.isFiltersCollectionViewHidden = false
            }
            
        case "SaveUnwindToAddActivity":
            // unwind from location
            let location = chosenLocationLabel.text ?? ""
            isChosenLocationHidden = location.isEmpty
            
        default:
            print("unidentifiable segue")
        }
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
        // print("did finish picking \(isCoverImageHidden)")
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
            
        case filtersCollectionViewIndexPath:
            return isFiltersCollectionViewHidden ? 0 : filtersCollectionView.intrinsicContentSize.height + 8
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFiltersSegue" {
            if let filterTableVC = segue.destination as? FiltersTableViewController {
                filterTableVC.filter = self.filter
            }
        }
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
