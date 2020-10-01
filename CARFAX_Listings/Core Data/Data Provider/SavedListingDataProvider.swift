//
//  SavedListingDataProvider.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import CoreData
import Foundation

class SavedListingDataProvider {
    private(set) var persistentContainer: NSPersistentContainer
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    var fetchedResultsController: NSFetchedResultsController<SavedListing>!
    
    init(with persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    private func configureFetchedResultsController() {
        let fetchRequest = SavedListing.fetch()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchedResultsController = NSFetchedResultsController<SavedListing>(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = fetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveListing(listing: Listing, completionHandler: (() -> Void)? = nil) {
        let taskContext = persistentContainer.backgroundContext()
        taskContext.perform {
            let newSavedListing = SavedListing(context: taskContext)
            newSavedListing.id = listing.id
            taskContext.save(with: .saveListing)
            completionHandler?()
        }
    }
    
    func removeListing(listingToRemove: SavedListing, completionHandler: (() -> Void)? = nil) {
        let taskContext = persistentContainer.backgroundContext()
        taskContext.performAndWait {
            taskContext.delete(listingToRemove)
            taskContext.save(with: .deleteListing)
            completionHandler?()
        }
    }
}
