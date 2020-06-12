//
//  HomepageTabBarViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

//    var myActivitiesTableViewController: MyActivitiesTableViewController!
//    var exploreTableViewController: ExploreTableViewController!
//    var addActivityTableViewController: AddActivityTableViewController!
//    var messagesTableViewController: MessagesTableViewController!
//    var meTableViewController: MeTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
//        // define view controllers
//        myActivitiesTableViewController = MyActivitiesTableViewController()
//        exploreTableViewController = ExploreTableViewController()
//        addActivityTableViewController = AddActivityTableViewController()
//        messagesTableViewController = MessagesTableViewController()
//        meTableViewController = MeTableViewController()
//
//        // set icons
//        myActivitiesTableViewController.tabBarItem.image = UIImage(systemName: "sun.min")
//        myActivitiesTableViewController.tabBarItem.selectedImage = UIImage(systemName: "sun.min.fill")
//
//        exploreTableViewController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
//        exploreTableViewController.tabBarItem.image = UIImage(systemName: "magnifyingglass") // need change
//
//        addActivityTableViewController.tabBarItem.image = UIImage(systemName: "plus")
//        addActivityTableViewController.tabBarItem.selectedImage = UIImage(systemName: "plus") // need change
//
//        messagesTableViewController.tabBarItem.image = UIImage(systemName: "message")
//        messagesTableViewController.tabBarItem.selectedImage = UIImage(systemName: "message.fill")
//
//        meTableViewController.tabBarItem.image = UIImage(systemName: "person")
//        meTableViewController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
//
//        // set tab bar's view controller
//        viewControllers = [myActivitiesTableViewController, exploreTableViewController, addActivityTableViewController, messagesTableViewController, meTableViewController]
//
//        // remove tab bar titles
//        for tabBarItem in tabBar.items! {
//            tabBarItem.title = ""
//            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        }
    }
    
//    // UI Tab bar delegate
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController.isKind(of: AddActivityTableViewController.self) {
//            let vc = AddActivityTableViewController()
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
//            // as long as you return false, the view controller won't be shown
//            return false
//        }
//        return true
//    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarItem.tag == 2 {
            let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.addActivityTableViewController) as? AddActivityTableViewController
            vc?.modalPresentationStyle = .currentContext
            self.present(vc!, animated: true, completion: nil)
        }
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
