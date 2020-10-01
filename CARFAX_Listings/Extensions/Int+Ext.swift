//
//  Int+Ext.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import Foundation

extension Int {
    func withComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    func currency() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
