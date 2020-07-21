//
//  ScheduleManager.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/18.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import UIKit

class ScheduleManager {
    
    var rootVC: UIViewController
    var currentUser: User
    var userSchedule: [Date]
    var todaySchedule: [Date] {
        if userSchedule.count == 0 {
            return []
        } else {
            var todaySchedule: [Date] = []
            let calender = Calendar.current
            for date in userSchedule {
                
                print(date)
                if calender.isDateInToday(date) {
                    let newDate = date.addingTimeInterval(8*60*60)
                    todaySchedule.append(newDate)
                }
            }
            return todaySchedule
        }
    }
    
    
    init(currentUser: User, rootVC: UIViewController) {
        self.currentUser = currentUser
        self.userSchedule = currentUser.schedule ?? []
        print(currentUser.schedule)
        self.rootVC = rootVC
    }
    
    func checkUpcomingActivitiesForToday() {
        if todaySchedule.count == 0 {
            return
        } else {
            // get today's activity
            for date in todaySchedule {
                // fire alert 10 mins before
                let reminderTime = date.addingTimeInterval(-10 * 60)
                print(reminderTime)
                let timer = Timer(fireAt: reminderTime, interval: 0, target: self, selector: #selector(displayAlerts), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: .common)
            }
            
        }
    }
    
    @objc func displayAlerts() {
        // create a app wise alert
        // get the activity name??
        let activityName = ""
        let alertController = UIAlertController(title: "Your Activity is starting in 10 mins", message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.rootVC.present(alertController, animated: true, completion: nil)
    }
    
    // a very crude way of doing this, update when update data structure
    func isUserFree(time: Date) -> Bool {
        if userSchedule.count == 0 {
            return true
        } else {
            for date in userSchedule {
                if date == time {
                    return false
                }
            }
            return true
        }
    }
}
