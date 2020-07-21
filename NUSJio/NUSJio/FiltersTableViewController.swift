//
//  FiltersTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/1.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class FiltersTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
//    let faculties = ["Arts & Social Science", "Business", "Computing", "Continuing and Lifelong Education", "Dentistry", "Design & Environment", "Duke-NUS", "Engineering", "Integrative Sciences & Engineering", "Law", "Medicine", "Music", "Public Health", "Public Policy", "Science", "USP", "Yale-NUS"]
    
//    let faculties = ["FASS", "BIZ", "SoC", "SCALE", "FoD", "SDE", "Duke-NUS", "Engineering", "NGS", "Law", "Medicine", "Music", "Public Health", "Public Policy", "Science", "USP", "Yale-NUS"]

    // model data
    var filter: Filter?
    var isEdited: Bool = false
    var categories: [String]? = nil {
        didSet {
            isEdited = true
            updateSaveButtonState()
        }
    }
    var numOfParticipants: Int? = nil {
        didSet {
            isEdited = true
            updateSaveButtonState()
            numOfParticipantsLabel.text = "\(String(describing: numOfParticipants!))"
        }
    }
    var selectedGender: Gender? = nil {
        didSet {
            isEdited = true
            updateSaveButtonState()
            selectedGenderLabel.text = selectedGender!.description
        }
    }
    
    var selectedFacultiesBoolArray = Array(repeating: false, count: Constants.numOfFaculties) {
        didSet {
            isEdited = true
            updateSaveButtonState()
        }
    }
    // var selectedFaculties: [String]?
    
    // UI data
    let facultySelectionCellIndexPath = IndexPath(row: 1, section: 3)
    
    // IB outlet
    @IBOutlet var categoriesLabel: UILabel!
    
    @IBOutlet var numOfParticipantsLabel: UILabel!
    @IBOutlet var numOfParticipantsSlider: UISlider!
    
    @IBOutlet var selectedGenderLabel: UILabel!
    @IBOutlet var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet var facultyCollectionView: UICollectionView!
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facultyCollectionView.dataSource = self
        facultyCollectionView.delegate = self
        facultyCollectionView.allowsMultipleSelection = true
        
        updateUI()
    }

    func updateUI() {
        categoriesLabel.textColor = UIColor.secondaryLabel
        selectedGenderLabel.textColor = UIColor.secondaryLabel
        numOfParticipantsLabel.textColor = UIColor.secondaryLabel
        
        numOfParticipantsSlider.minimumValue = 0
        numOfParticipantsSlider.maximumValue = 15
        
        genderSegmentedControl.setTitle("Mixed Gender", forSegmentAt: 0)
        genderSegmentedControl.setTitle("Males Only", forSegmentAt: 1)
        genderSegmentedControl.setTitle("Females Only", forSegmentAt: 2)
        
        if let filter = filter {
            // categories
            if let categories = filter.categories {
                categoriesLabel.text = categories.reduce("") { (result, string) -> String in
                    return result + ", " + string
                }
            } else {
                categoriesLabel.text = "No category chosen"
            }
            
            // number of participants
            if let numOfParticipants = filter.numOfParticipants {
                numOfParticipantsLabel.text = "\(String(describing: numOfParticipants))"
                let float = Float(numOfParticipants)
                numOfParticipantsSlider.value = float
            } else {
                numOfParticipantsLabel.text = "No limit"
                numOfParticipantsSlider.value = 0
            }
            
            // gender
            if let gender = filter.gender {
                selectedGender = gender
                switch gender {
                case .mixed:
                    genderSegmentedControl.selectedSegmentIndex = 0
                case .male:
                    genderSegmentedControl.selectedSegmentIndex = 1
                case .female:
                    genderSegmentedControl.selectedSegmentIndex = 2
                }
            } else {
                genderSegmentedControl.selectedSegmentIndex = 0
                selectedGenderLabel.text = "No preference"
            }
            
            selectedFacultiesBoolArray = filter.selectedFacultiesBoolArray
            
        } else {
            // categories, from categories table view
            if let categories = categories {
                categoriesLabel.text = categories.reduce("") { (result, string) -> String in
                    return result + " " + string
                }
            } else {
                categoriesLabel.text = "No category chosen"
            }
            
            numOfParticipantsLabel.text = "No limit"
            selectedGenderLabel.text = "No preference"
        }
        
    }
    
    @IBAction func participantsSliderValueChanged(_ sender: UISlider) {
        numOfParticipants = Int(sender.value)
    }
    
    @IBAction func genderSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        
        switch selectedIndex {
        case 0:
            selectedGender = .mixed
        case 1:
            selectedGender = .male
        case 2:
            selectedGender = .female
        default:
            print("gender selection out of bound")
        }
    }
    
    @IBAction func unwindToFiltersTableWithSegue(segue: UIStoryboardSegue) {
        updateUI()
    }
    
    func updateSaveButtonState() {
        if isEdited {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    // table view
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case facultySelectionCellIndexPath:
            return 330
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.faculties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = facultyCollectionView.dequeueReusableCell(withReuseIdentifier: "facultyCell", for: indexPath) as! FacultyCollectionViewCell
        let index = indexPath.item
        cell.facultyLabel.text = Constants.faculties[index]
        if let filter = filter {
            // print(filter.selectedFacultiesBoolArray)
            if filter.selectedFacultiesBoolArray[index] {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        selectedFacultiesBoolArray[index] = true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        selectedFacultiesBoolArray[index] = false
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveFromFilterToAddActivity" {
            guard let addActivityVC =  segue.destination as? AddActivityTableViewController else {return}
            if isEdited {
                // print(facultyCollectionView.indexPathsForSelectedItems?.map{faculties[$0.item]})
                
                let selectedFaculties = facultyCollectionView.indexPathsForSelectedItems?.map{Constants.faculties[$0.item]}
                // print(selectedFacultiesBoolArray)
                let filter = Filter(categories: self.categories, numOfParticipants: self.numOfParticipants, gender: self.selectedGender, faculties: selectedFaculties, selectedFacultiesBoolArray: self.selectedFacultiesBoolArray)
                // pass it to add activity
                addActivityVC.filter = filter
            } else {
                print("don't pass any filter")
            }
            
        }
    }

}
