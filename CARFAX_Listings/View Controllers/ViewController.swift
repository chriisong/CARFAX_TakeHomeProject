//
//  ViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.shared.getListing { result in
            switch result {
            case .failure(let error): print(error.rawValue)
            case .success(let listings):
                print(listings.listings.count)
            }
        }
        
    }


}

