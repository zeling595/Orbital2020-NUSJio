//
//  CategoriesTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/1.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    let categories: [CategoryItem] = CategoryItem.loadListOfCategories()
    
    var selectedCategories: [CategoryItem] {
        return categories.filter { return $0.isSelected }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as? CategoryTableViewCell else {
            fatalError("cannot dequeue the cell")
        }
        
        cell.textLabel?.text = categories[indexPath.row].categoryTitle
        
        if categories[indexPath.row].isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categories[indexPath.row].isSelected = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        categories[indexPath.row].isSelected = false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveToFiltersTableSegue" {
            if let filtersTableVC = segue.destination as? FiltersTableViewController {
//                let categories = selectedCategories.map({ $0.categoryTitle }).reduce("") { (result, string) -> String in
//                    return result + " " + string
//                }
                filtersTableVC.categories = selectedCategories.map({ $0.categoryTitle })
            }
            
        }
    }

}
