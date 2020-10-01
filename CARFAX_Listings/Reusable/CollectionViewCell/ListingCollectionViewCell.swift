//
//  ListingCollectionViewCell.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class ListingCollectionViewCell: CFCollectionViewCell {
    private var carImageView: CFListingImageView!
    private var carMakeLabel: CFLabel!
    private var priceLabel: CFLabel!
    private var mileageLabel: CFLabel!
    private var locationLabel: CFLabel!
    
    var phoneButton: CFButton!
    var mapButton: CFButton!
    
    private var labelStackView: CFStackView!
    private var buttonStackView: CFStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configure() {
        configurePhoneButton()
        configureMapButton()
        configureLabels()
        configureStackViews()
        carImageView = CFListingImageView(frame: bounds)
        addSubviews(carImageView, labelStackView, buttonStackView)
        
        let inset = CGFloat(10)
        
        NSLayoutConstraint.activate([
            carImageView.topAnchor.constraint(equalTo: topAnchor),
            carImageView.widthAnchor.constraint(equalTo: widthAnchor),
            carImageView.heightAnchor.constraint(equalToConstant: 225),
            
            labelStackView.topAnchor.constraint(equalTo: carImageView.bottomAnchor, constant: inset * 2),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            labelStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65),
            
//            buttonStackView.leadingAnchor.constraint(equalTo: labelStackView.trailingAnchor, constant: inset * 2),
            buttonStackView.topAnchor.constraint(equalTo: carImageView.bottomAnchor, constant: inset * 2),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            buttonStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: DeviceTypes.isiPad ? 0.1 : 0.3)
        ])
    }
    
    func set(with listing: Listing) {
        if let smallImageURL = listing.images.firstPhoto?.large {
            NetworkManager.shared.downloadImage(from: smallImageURL) { image in
                DispatchQueue.main.async {
                    self.carImageView.image = image
                }
            }
        }
        let year = listing.year
        let make = listing.make.rawValue
        let model = listing.model
        let city = listing.dealer.city
        let state = listing.dealer.state.rawValue
        let listingTitle = "\(year) \(make) \(model)"
        let listingDealerLocation = "\(city), \(state)"
        carMakeLabel.text = listingTitle
        priceLabel.text = listing.listPrice.currency()
        mileageLabel.text = listing.mileage.withComma() + " miles"
        locationLabel.text = listingDealerLocation
    }
    
    private func configurePhoneButton() {
        phoneButton = CFButton(frame: bounds)
        phoneButton.setImage(Image.phoneIcon, for: .normal)
        phoneButton.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
    }
    
    private func configureMapButton() {
        mapButton = CFButton(frame: bounds)
        mapButton.setImage(Image.mapIcon, for: .normal)
        mapButton.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
    }
    
    private func configureLabels() {
        carMakeLabel = CFLabel(frame: bounds, font: UIFont.preferredFont(forTextStyle: .title3).bold(), textColor: .white)
        priceLabel = CFLabel(frame: bounds, font: UIFont.preferredFont(forTextStyle: .headline).bold(), textColor: .white)
        mileageLabel = CFLabel(frame: bounds, font: UIFont.preferredFont(forTextStyle: .headline), textColor: .white)
        locationLabel = CFLabel(frame: bounds, font: UIFont.preferredFont(forTextStyle: .headline), textColor: .white)
    }
    
    private func configureStackViews() {
        labelStackView = CFStackView(frame: bounds, axis: .vertical, spacing: 5, distribution: .fill)
        buttonStackView = CFStackView(frame: bounds, axis: .vertical, spacing: 5, distribution: .fillEqually)
        
        labelStackView.addArrangedSubview(carMakeLabel)
        labelStackView.addArrangedSubview(priceLabel)
        labelStackView.addArrangedSubview(mileageLabel)
        labelStackView.addArrangedSubview(locationLabel)
        
        buttonStackView.addArrangedSubview(phoneButton)
        buttonStackView.addArrangedSubview(mapButton)
    }
}
