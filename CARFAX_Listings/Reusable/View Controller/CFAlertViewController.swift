//
//  CFAlertViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFAlertViewController: UIViewController {
    
    private var alertTitle: String?
    private var message: String?
    private var buttonTitle: String?
    
    var containerView: CFAlertContainerView!
    
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        containerView = CFAlertContainerView(title: title, message: message, buttonTitle: buttonTitle, action: dismissVC)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismissVC() {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        view.addSubview(containerView)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }
}
