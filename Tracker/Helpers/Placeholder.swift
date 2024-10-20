//
//  placeholder.swift
//  Tracker
//
//  Created by big stepper on 14/10/2024.
//

import UIKit


final class Placeholder {
    
    //MARK: - Singletone
    
    static let shared = Placeholder()
    
    private init(){}
    
    //MARK: - Properties
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    //MARK: - Methods
    
    func showPlaceholder(image: UIImage, text: String, view: UIView) {
        view.addSubview(placeholderStackView)
        
        placeholderLabel.text = text
        placeholderImageView.image = image
        
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func removePlaceholder() {
        placeholderStackView.removeFromSuperview()
    }

}
