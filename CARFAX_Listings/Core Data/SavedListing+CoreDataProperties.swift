//
//  SavedListing+CoreDataProperties.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//
//

import Foundation
import CoreData


extension SavedListing {

    @nonobjc public class func fetch() -> NSFetchRequest<SavedListing> {
        return NSFetchRequest<SavedListing>(entityName: "SavedListing")
    }

    @NSManaged public var id: String

}

extension SavedListing : Identifiable {

}
