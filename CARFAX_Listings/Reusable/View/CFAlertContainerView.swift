//
//  CFAlertContainerView.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class CFAlertContainerView: UIView {
    var titleLabel: CFLabel!
    var messageLabel: CFLabel!
    var actionButton: CFButton!
    
    private var alertTitle: String?
    private var message: String?
    private var buttonTitle: String?
    private var action: (() -> Void)?
    
    let inset: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(frameRect: CGRect) {
        super.init(frame: frameRect)
        configureForModal()
    }
    
    init(title: String, message: String, buttonTitle: String, action: (@escaping () -> Void)) {
        super.init(frame: .zero)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
        configureForAlert()
    }
    
    required init?(coder: NSCoder) { fatalError("") }
    
    private func configureForModal() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 20
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
    }
    
    private func configureForAlert() {
        titleLabel = CFLabel(frame: bounds, font: UIFont.preferredFont(forTextStyle: .title3).bold(), textColor: .label)
        messageLabel = CFLabel(frame: bounds, font: UIFont.preferredFont(forTextStyle: .body), textColor: .label)
        actionButton = CFButton(frame: bounds)
        
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
        actionButton.backgroundColor = .systemPink
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionButton)
        
        backgroundColor = .systemGray6
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            titleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12),
            
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        titleLabel.text = alertTitle ?? "Something went wrong here"
        messageLabel.text = message ?? "Unable to complete request"
        actionButton.setTitle(buttonTitle ?? "OK", for: .normal)
        
        actionButton.addTarget(self, action: #selector(dismissPressed), for: .touchUpInside)
    }
    
    @objc func dismissPressed() {
        action?()
    }

}
