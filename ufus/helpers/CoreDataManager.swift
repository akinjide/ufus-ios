//
//  CoreDataManager.swift
//  ufus
//
//  Created by Akinjide Bankole on 10/10/17.
//  Copyright © 2017 Akinjide Bankole. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    class func storeObject(shortUrl: String, longUrl: String, urlHash: String, addedAt: Date) -> History {
        let context = getContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "HistoryEntity", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)

        managedObject.setValue(shortUrl, forKey: "short_url")
        managedObject.setValue(longUrl, forKey: "long_url")
        managedObject.setValue(urlHash, forKey: "url_hash")
        managedObject.setValue(addedAt, forKey: "added_at")

        do {
            try context.save()
            print("saved")
        } catch {
            print(error.localizedDescription)
        }
        
        return History(short_url: shortUrl, long_url: longUrl, added_at: addedAt)
    }

    class func loadObject() -> [History] {
        var historyList = [History]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryEntity")

        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "added_at", ascending: false)]
        // .sorted(by: { $0.added_at.compare($1.added_at) == .orderedDescending })

        do {
            let fetchResults = try getContext().fetch(request)
            
            if fetchResults.count > 0 {
                for result in fetchResults as! [NSManagedObject] {
                    let shortUrl = result.value(forKey: "short_url") as? String ?? ""
                    let longUrl = result.value(forKey: "long_url") as? String ?? ""
                    let addedAt = result.value(forKey: "added_at") as? Date ?? Date()

                    historyList.append(History(short_url: shortUrl, long_url: longUrl, added_at: addedAt))
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return historyList
    }
    
    class func remove(shortUrl: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryEntity")
        request.predicate = NSPredicate(format: "short_url == %@", shortUrl)

        do {
            try getContext().execute(NSBatchDeleteRequest(fetchRequest: request))
            print("removed")
        }
        catch {
            print(error.localizedDescription)
            return false
        }
        
        return true
    }
}
