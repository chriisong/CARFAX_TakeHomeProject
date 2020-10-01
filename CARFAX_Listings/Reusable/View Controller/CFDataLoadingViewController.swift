//
//  CFDataLoadingViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-10-01.
//

import UIKit

class CFDataLoadingViewController: UIViewController {
    private var loadingContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLoadingView() {
        guard loadingContainerView == nil else { return }
        
        loadingContainerView = UIView(frame: view.bounds)
        view.addSubview(loadingContainerView)
        loadingContainerView.backgroundColor = .systemBackground
        loadingContainerView.alpha = 0
        UIView.animate(withDuration: 0.25) { self.loadingContainerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        loadingContainerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: loadingContainerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        guard loadingContainerView != nil else { return }
        
        DispatchQueue.main.async {
            self.loadingContainerView.removeFromSuperview()
            self.loadingContainerView = nil
        }
    }
}
