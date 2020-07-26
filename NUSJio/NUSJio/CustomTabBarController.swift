//
//  HomepageTabBarViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol CustomTabBarDelegate: class {
    func goTo(index: Int, activity: Activity)
}

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate, CustomTabBarDelegate {
    
    // not in use now
    var currentUser: User!
    var dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetch current user, not in use now
        if let firebaseUser = Auth.auth().currentUser {
            dataController.fetchUser(userId: firebaseUser.uid) { (user) in
                if let user = user {
                    self.currentUser = user
                    print(user)
                }
            }
        }
        
        // navigation bar
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Styles.themeBlue]
        UINavigationBar.appearance().tintColor = Styles.themeOrange
        
        self.delegate = self
        
        // tab bar
        UITabBar.appearance().tintColor = Styles.themeOrange
        UITabBar.appearance().unselectedItemTintColor = Styles.themeBlue
    }
    
    // UI Tab bar delegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // modally present the add controller
        if let navController = viewController as? UINavigationController, navController.topViewController?.isKind(of: AddActivityTableViewController.self) ?? false {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nav = storyboard.instantiateViewController(identifier: "AddActivityNavigationController") as! UINavigationController
            self.present(nav, animated: true) {
                if let addActivityVC = nav.topViewController as? AddActivityTableViewController {
                    addActivityVC.delegate = self
                    // print("(print from tab bar should select \(addActivityVC.delegate)")
                }
            }
            return false
        }
        return true
    }

    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if tabBarItem.tag == 2 {
//            let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.addActivityTableViewController) as? AddActivityTableViewController
//            vc?.modalPresentationStyle = .automatic
//            self.present(vc!, animated: true, completion: nil)
//        }
        print("(print from tabbar controller) \(tabBarController.selectedIndex)")
        // if tabBarItem.tag == 
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func goTo(index: Int, activity: Activity) {
        // print("(print from tab bar) go to \(activity)")
        if index == 0 {
            self.selectedIndex = index
            goToActivityDetail(activity: activity)
        } else if index == 2 {
            // print("(print from tab bar go to) \(selectedIndex)")
            goBackToAddActivity(activity: activity)
        }
        
    }
    
    private func goToActivityDetail(activity: Activity) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstNavController = storyboard.instantiateViewController(identifier: "MyActivitiesNavigationController") as! UINavigationController
        let activityDetailVC = storyboard.instantiateViewController(identifier: "ActivityDetailViewController") as! ActivityDetailViewController
        activityDetailVC.activity = activity
        // seem to work
        self.viewControllers?[0] = firstNavController
        self.selectedIndex = 0
        firstNavController.pushViewController(activityDetailVC, animated: true)
    }
    
    private func goBackToAddActivity(activity: Activity) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let thirdNavController = selectedViewController as! UINavigationController
        let thirdNavController = storyboard.instantiateViewController(identifier: "AddActivityNavigationController") as UINavigationController
        let addActivityVC = storyboard.instantiateViewController(identifier: "AddActivityTableViewController") as! AddActivityTableViewController
        addActivityVC.activity = activity
        addActivityVC.delegate = self
        thirdNavController.pushViewController(addActivityVC, animated: true)
        self.present(thirdNavController, animated: true) {
            print("(print from go back to add activity) present")
        }
    }

}


