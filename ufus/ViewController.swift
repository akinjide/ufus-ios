//
//  ViewController.swift
//  ufus
//
//  Created by Akinjide Bankole on 9/14/17.
//  Copyright © 2017 Akinjide Bankole. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate {
    
    let notificationIdentifier = "notificationIdentifier"
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = UIColor.darkGray

        longUrl.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var longUrl: UITextField!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.makeHTTPRequest(longUrl: textField.text!)
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func highlightAndCopyTextFieldContent(_: Void) -> Void {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        self.longUrl.becomeFirstResponder()
        self.longUrl.selectedTextRange = self.longUrl.textRange(from: self.longUrl.beginningOfDocument, to: self.longUrl.endOfDocument)
//        UIPasteboard.general.string = self.longUrl.text!
//        self.authorizePushNotification(shortUrl: self.longUrl.text!)

        if let longUrl = self.longUrl.text {
            UIPasteboard.general.string = longUrl
            self.authorizePushNotification(shortUrl: longUrl)
        } else {
            self.alertView(message: "Copy your shortened url.")
        }
    }

    func authorizePushNotification(shortUrl: String) -> Void {
        let content = UNMutableNotificationContent()
        let copy = UNNotificationAction(identifier: "copy", title: "Copy", options: .foreground)
        let category = UNNotificationCategory(identifier: "category", actions: [copy], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        content.title = "Link Shortened"
        content.body = shortUrl
        content.categoryIdentifier = "category"
        
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

    func convertToDictionary(text: String) -> [String: Any]? {

        // JSONSerialization.ReadingOptions.mutableContainers
        // String(data: data, encoding: .utf8)

        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }

        return nil
    }

    func alertView(title: String = "", message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func makeHTTPRequest(longUrl: String) -> Void {
        view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        var request = URLRequest(url: URL(string: "http://api.ufus.cc/v1/shorten")!)
        request.httpMethod = "POST"
        
        let postString = "long_url=" + longUrl
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Background queue
            DispatchQueue.global(qos: .background).async {
                
                // Main queue
                DispatchQueue.main.async {
                    // check for fundamental networking error
                    guard let data = data, error == nil else {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.alertView(message: "Aw, Snaps! The Internet connection appears to be offline.")
                        return
                    }
                    
                    let json = self.convertToDictionary(text: String(data: data, encoding: .utf8)!)!
                    
                    // check for http errors
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.alertView(message: "Oops! You are trying to do something useful.")
                    }
                    
                    if let shortUrl = json["short_url"] {
                        self.longUrl.text = shortUrl as? String
                        self.highlightAndCopyTextFieldContent()
                    }
                }
            }

        }
        
        task.resume()
    }

}

