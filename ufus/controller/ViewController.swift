//
//  ViewController.swift
//  ufus
//
//  Created by Akinjide Bankole on 9/14/17.
//  Copyright © 2017 Akinjide Bankole. All rights reserved.
//

import UIKit
import CoreData

struct History {
    let short_url: String
    let long_url: String
    let added_at: Date
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    let notificationManager: NotificationManager = NotificationManager()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle(rawValue: 20)!)
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 60, width: (UIScreen.main.bounds.width), height: 60))
    var refresher: UIRefreshControl!
    var linkHistory = [History]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        longUrl.delegate = self
        self.searchBar.delegate = self
        
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = UIColor.darkGray
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ViewController.viewDidPopulate), for: UIControlEvents.valueChanged)
        refresher.backgroundColor = UIColor.white
        recentTableView.addSubview(refresher)
        self.linkHistory = CoreDataManager.loadObject()
        
        if linkHistory.count == 0 {
            recentTableView?.isHidden = true
        }
        
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.keyboardType = .URL
        searchBar.keyboardAppearance = .dark
        self.definesPresentationContext = true
        recentTableView.sectionHeaderHeight = 70
        recentTableView.tableHeaderView = self.searchBar

        recentTableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
        recentTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            linkHistory = CoreDataManager.loadObject()
            recentTableView.reloadData()
            return
        }
        
        filterTableViewContent(for: searchText)
        recentTableView.reloadData()
    }
    
    func filterTableViewContent(for searchText: String) {
        let searchText = searchText.lowercased()
        
        linkHistory = linkHistory.filter { (history) -> Bool in
            return history.short_url.lowercased().contains(searchText) ||
                history.long_url.lowercased().contains(searchText)
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell

        let userViewData = self.linkHistory[indexPath.row]
        
        cell.historyTitle?.text = userViewData.long_url
        cell.historySubtitle?.text = userViewData.short_url
        cell.historyTime?.text = userViewData.added_at.timeDisplay()
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userViewData = self.linkHistory[indexPath.row]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Copy Link", style: .default, handler: { (action) in
            UIPasteboard.general.string = userViewData.short_url
            self.alertView(title: nil, message: "Copied", alertType: "popup")
        }))
        
        alert.addAction(UIAlertAction(title: "Copy Original Link", style: .default, handler: { (action) in
            UIPasteboard.general.string = userViewData.long_url
            self.alertView(title: nil, message: "Copied", alertType: "popup")
        }))
        
        alert.addAction(UIAlertAction(title: "View in Browser", style: .default, handler: { (action) in
            UIApplication.shared.open(NSURL(string: userViewData.short_url)! as URL, options: [:], completionHandler: nil)
        }))

        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
            let removeHistory = self.linkHistory.remove(at: indexPath.row)
            _ = CoreDataManager.remove(shortUrl: removeHistory.short_url)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            if self.linkHistory.count == 0 {
                self.recentTableView?.isHidden = true
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let copyAction: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Copy") { (action, indexPath) in
            let userViewData = self.linkHistory[indexPath.row]
            UIPasteboard.general.string = userViewData.short_url
            self.alertView(title: nil, message: "Copied", alertType: "popup")
        }

        let removeAction: UITableViewRowAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            let removeHistory = self.linkHistory.remove(at: indexPath.row)
            _ = CoreDataManager.remove(shortUrl: removeHistory.short_url)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            if self.linkHistory.count == 0 {
                self.recentTableView?.isHidden = true
            }
        }

        return [removeAction, copyAction]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: (UIScreen.main.bounds.width), height: 50))
        let borderLayer = CALayer()
        
        label.text = "Recents"
        label.font = UIFont.boldSystemFont(ofSize: 36.0)
        label.textColor = UIColor.black
        header.backgroundColor = UIColor.white
        borderLayer.backgroundColor = UIColor.lightGray.cgColor
        borderLayer.frame = CGRect(x: 0, y: (label.frame.height + 19), width: header.frame.width, height: 0.5)

        header.addSubview(label)
        header.layer.addSublayer(borderLayer)

        return header
    }
    
    @IBOutlet weak var recentTableView: UITableView!
    @IBOutlet weak var longUrl: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.makeHTTPRequest(longUrl: textField.text!)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func highlightAndCopyTextFieldContent(newHistory: History) -> Void {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        self.longUrl.becomeFirstResponder()
        self.longUrl.selectedTextRange = self.longUrl.textRange(from: self.longUrl.beginningOfDocument, to: self.longUrl.endOfDocument)

        if let shortUrl = self.longUrl.text {
            UIPasteboard.general.string = shortUrl
            self.linkHistory.insert(newHistory, at: 0)
            recentTableView.reloadData()
            
            if recentTableView.isHidden {
                recentTableView?.isHidden = false
            }
            
            notificationManager.authorizePushNotification(shortUrl)
        } else {
            self.alertView(title: nil,
                           message: "Copy Link",
                           alertType: "popupWithAction")
        }
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }

        return nil
    }

    func alertView(title: String?, message: String?, alertType: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if alertType == "popup" {
            self.present(alert, animated: true) {
                let delay_s: Double = 0.1
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay_s, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            }
        } else {
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
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
                        self.alertView(title: nil,
                                       message: "Aw, Snaps! The Internet connection appears to be offline.",
                                       alertType: "popupWithAction")
                        return
                    }
                    
                    // check for http errors
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.alertView(title: nil,
                                       message: "Oops! You are trying to do something useful.",
                                       alertType: "popupWithAction")
                    }
                    
                    if let json = self.convertToDictionary(text: String(data: data, encoding: .utf8)!) {
                        if json["status"] as! Int == 200 {
                            let shortUrl = json["short_url"] as! String
                            let newHistory = CoreDataManager
                                .storeObject(shortUrl: shortUrl,
                                             longUrl: json["long_url"] as! String,
                                             urlHash: json["hash"] as! String,
                                             addedAt: Date())
                            self.longUrl.text = shortUrl
                            self.highlightAndCopyTextFieldContent(newHistory: newHistory)
                        } else {
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.alertView(title: nil,
                                           message: "Oops! You are trying to do something useful.",
                                           alertType: "popupWithAction")
                        }
                    }
                }
            }

        }
        
        task.resume()
    }

    func viewDidPopulate() {
        self.linkHistory = CoreDataManager.loadObject()
        recentTableView.reloadData()
        refresher.endRefreshing()
    }
}
