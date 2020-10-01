//
//  Double+Ext.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-10-01.
//

import Foundation

extension Double {
    func currency() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
