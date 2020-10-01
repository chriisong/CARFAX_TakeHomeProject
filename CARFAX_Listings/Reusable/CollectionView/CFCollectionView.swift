//
//  CFCollectionView.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configure() {
        backgroundColor = .systemGroupedBackground
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
