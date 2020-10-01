//
//  UIViewController+Ext.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-10-01.
//

import UIKit

extension UIViewController {
    func presentCFAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = CFAlertViewController(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
}
