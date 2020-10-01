//
//  DetailedListingImageViewCell.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-10-01.
//

import UIKit

class DetailedListingImageViewCell: CFCollectionViewCell {
    var carImageView: CFListingImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configure() {
        carImageView = CFListingImageView(frame: bounds)
        addSubview(carImageView)
        
        NSLayoutConstraint.activate([
            carImageView.widthAnchor.constraint(equalTo: widthAnchor),
            carImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            carImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            carImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        selectedBackgroundView = UIView()
    }
    func setImage(for listing: Listing, _ indexPath: IndexPath) {
        let baseURL = listing.images.baseURL
        let imageCount = indexPath.item + 1
        let suffix = "/640x480"
        let newURL = baseURL + String(imageCount) + suffix
        
        NetworkManager.shared.downloadImage(from: newURL) { image in
            DispatchQueue.main.async {
                self.carImageView.image = image
            }
        }
    }
}
