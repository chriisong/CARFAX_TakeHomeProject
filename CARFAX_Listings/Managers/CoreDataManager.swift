//
//  CoreDataManager.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import CoreData
import UIKit

enum ContextSaveContextualInfo: String {
    case saveListing = "saving a listing"
    case deleteListing = "deleting a listing"
}

class CoreDataManager {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "CARFAX_Listings")

        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Failed to load persistent stores: \(error)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()

}

extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        return newBackgroundContext()
    }
}

extension NSManagedObjectContext {
    private func handleSavingError(_ error: Error, contextualInfo: ContextSaveContextualInfo) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window,
                let viewController = window?.rootViewController else { return }
            
            let message = "Failed to save the context when \(contextualInfo.rawValue)."
            
            // Append message to existing alert if present
            if let currentAlert = viewController.presentedViewController as? UIAlertController {
                currentAlert.message = (currentAlert.message ?? "") + "\n\n\(message)"
                return
            }
            
            // Otherwise present a new alert
            let alert = UIAlertController(title: "Core Data Saving Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }
    func save(with contextualInfo: ContextSaveContextualInfo) {
        guard hasChanges else { return }
        
        do {
            try save()
        } catch {
            handleSavingError(error, contextualInfo: contextualInfo)
        }
    }
}
