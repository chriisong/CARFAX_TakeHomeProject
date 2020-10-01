//
//  CFCollectionViewCell.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) { fatalError("") }

    private func configure() {
        backgroundColor = .systemGray4
        layer.cornerRadius = 16
        clipsToBounds = true
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        selectedBackgroundView?.layer.cornerRadius = 16
    }
}
