//
//  CFLabel.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFLabel: UILabel {
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        let descriptor = font.fontDescriptor
        if let rounded = descriptor.withDesign(.rounded) {
            self.font = UIFont(descriptor: rounded, size: 0)
            self.textColor = textColor
        } else {
            self.font = font
            self.textColor = textColor
        }
        self.textAlignment = .left
        configure()
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        drawShadow()
    }
    
    private func drawShadow() {
        layer.shadowOpacity = 0.8
        layer.masksToBounds = false
        clipsToBounds = false
        layer.shadowRadius = 0.75
        layer.shadowOffset = CGSize(width: 1.25, height: 1.25)
        layer.shadowColor = UIColor.black.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
