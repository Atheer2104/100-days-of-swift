//
//  ViewController.swift
//  projectTwentyOne
//
//  Created by Atheer on 2019-06-13.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
    }
    
    @objc func registerLocal() {
        // getting access to our current notification center
        let center = UNUserNotificationCenter.current()
        // we are asking for permission if we could send notifications
        // we are going to show an message/alert, a bagde and play sound
        // the user could either give us permission or there could be an error
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("YAYY")
            }else {
                print("D'oh!")
            }
        }
        
        
    }
    
    @objc func scheduleLocal() {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        // will remove all notification that will be sent
        center.removeAllPendingNotificationRequests()
        
        
        let content = UNMutableNotificationContent()
        // this will be shown on the bigger text on the notification
        content.title = "Late wake up call"
        // for longer text
        content.body = "The early bird catches the worm, but the second mouse gets the chesse."
        content.categoryIdentifier = "alarm"
        // the code below code be used for example to when user opens the notifcation
        // it will redirect the user to the thing/content like snapchat
        content.userInfo = ["customData": "fizzbuzz"]
        // default sound for notifications
        content.sound = .default
        
        /*
        var dateComponents = DateComponents()
        // when the hour is 10 and the minute is 30 ie 10:30
        dateComponents.hour = 10
        dateComponents.minute = 30
        
        // repeats tells it if it should repeat every time at the specfied time
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        */
        
        // this trigger will be activated after 5 seconds when we pressed the
        // rightbarbutto
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
    }
    
    func registerCategories() {
         let center = UNUserNotificationCenter.current()
        // any message from notification gets ported back to this view
        center.delegate = self
        
        // identifier is string so we know what button we tapped
        // the .foreground tell that if the button is tapped
        // then it should launch the app immediately
        let show = UNNotificationAction(identifier: "show", title: "Tell me more", options: [.foreground])
        
        // same identifier as we specified earlier
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // if we can read our value that we saved with the notification
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data recived: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
            case "show":
                // the user tapped our show more button
                print("Show more information")
            default:
                break
            }
        }
        
        // regardless if we could get our userInfo data
        // or not we must call this function because of the method
        // it has escaping that means this method doesn't have to be finished now
        // it could take 5 or 10 minutes but we tell we are done by calling
        // completionHandler    
        completionHandler()
        
    }


}

