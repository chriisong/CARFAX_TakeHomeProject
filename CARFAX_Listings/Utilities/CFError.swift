//
//  CFError.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import Foundation

enum CFError: String, Error {
    case invalidResponse = "Invalid response from the server. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection and try again."
    case invalidData = "The data received from the server was invalid. Please try again."
}
