//
//  CFListingImageView.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFListingImageView: UIImageView {
    let cache = NetworkManager.shared.cache
    let placeholderImage = Image.listingPlaceholderImage
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configure() {
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill
    }
}
