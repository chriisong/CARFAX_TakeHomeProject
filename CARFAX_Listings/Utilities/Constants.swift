//
//  Constants.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

enum Image {
    static let listingPlaceholderImage      = UIImage(systemName: "car.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    static let phoneIcon                    = UIImage(systemName: "phone", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    static let mapIcon                      = UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!
    static let ellipsisCircleFill           = UIImage(systemName: "ellipsis.circle.fill")!
    static let arrowUpArrowDownSquareFill   = UIImage(systemName: "arrow.up.arrow.down.square.fill")!
    static let dollarSignSquareFill         = UIImage(systemName: "dollarsign.square.fill")!
    static let arrowDownHeartFill           = UIImage(systemName: "arrow.down.heart.fill")!
    static let listingTabBarImage           = UIImage(systemName: "list.bullet.rectangle")!
    static let savedTabBarImage             = UIImage(systemName: "heart.fill")!
    static let trashCircleFill              = UIImage(systemName: "trash.circle.fill")!
}

enum ScreenSize {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}

enum DeviceTypes {
    static let idiom        = UIDevice.current.userInterfaceIdiom
    static let orientation  = UIDevice.current.orientation
    static let nativeScale  = UIScreen.main.nativeScale
    static let scale        = UIScreen.main.scale
    
    static let isiPhoneSE               = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength >= 1024.0
    
    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
    
    static let isiPadLandScapeMode  = (isiPad && orientation == .landscapeRight) || (isiPad && orientation == .landscapeLeft)
    static let isLandscape          = orientation.isLandscape
    static let isPortrait           = orientation.isPortrait
}

enum SortOptions {
    case priceHigh, priceLow, mileHigh, mileLow
    var title: String {
        switch self {
        case .priceHigh: return "Price High to Low"
        case .priceLow: return "Price Low to High"
        case .mileHigh: return "Mile High to Low"
        case .mileLow: return "Mile Low to High"
        }
    }
}
