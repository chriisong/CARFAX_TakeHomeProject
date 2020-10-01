//
//  CFStackView.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFStackView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution) {
        super.init(frame: frame)
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) { fatalError("") }
    
}
