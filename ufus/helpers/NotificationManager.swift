//
//  NotificationManager.swift
//  ufus
//
//  Created by Akinjide Bankole on 10/6/17.
//  Copyright © 2017 Akinjide Bankole. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {
    let notificationIdentifier = "notificationIdentifier"
    
    // Shared instance
    static let shared:NotificationManager = {
        return NotificationManager()
    }()
    
    func authorizePushNotification(_ shortUrl: String, title: String = "link_shortened".localized()) -> Void {
        let content = UNMutableNotificationContent()
        let copy = UNNotificationAction(identifier: "copy", title: "copy".localized(), options: .foreground)
        let category = UNNotificationCategory(identifier: "category", actions: [copy], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        content.title = title
        content.body = shortUrl
        content.categoryIdentifier = "category"
        content.sound = UNNotificationSound.default()
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.sendPushNotification(content: content)
            }
            else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        if granted {
                            self.sendPushNotification(content: content)
                        }
                    }
                })
            }
        }
    }
    
    func sendPushNotification(content: UNMutableNotificationContent) -> Void {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error)
            }
            else {
                print("notified")
            }
        }
    }
}
