//
//  UIFont+Ext.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

extension UIFont {
    func setToRounded() -> UIFont {
        let descriptor = self.fontDescriptor
        if let rounded = descriptor.withDesign(.rounded) {
            return UIFont(descriptor: rounded, size: 0)
        } else {
            return self
        }
    }
    
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}
