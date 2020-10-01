//
//  MainTabBarController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    private func configure() {
        view.backgroundColor = .systemBackground
        viewControllers = [createListingVC(), createSavedListingVC()]
        UITabBar.appearance().tintColor = .systemPink
    }
    
    private func createListingVC() -> UINavigationController {
        let vc = ListingViewController()
        vc.tabBarItem = UITabBarItem(title: "Listings", image: Image.listingTabBarImage, selectedImage: nil)
        return UINavigationController(rootViewController: vc)
    }
    
    private func createSavedListingVC() -> UINavigationController {
        let vc = SavedListingViewController()
        vc.tabBarItem = UITabBarItem(title: "Saved", image: Image.savedTabBarImage, selectedImage: nil)
        return UINavigationController(rootViewController: vc)
    }
}
