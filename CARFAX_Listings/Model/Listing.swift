//
//  Listing.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import Foundation

struct Listing: Codable, Hashable {
    let advantage: Bool
    let backfill: Bool
    let badge: String
    let bedLength: String
    let bodytype: String
    let cabType: String
    let certified: Bool
    let currentPrice: Double
    
}
