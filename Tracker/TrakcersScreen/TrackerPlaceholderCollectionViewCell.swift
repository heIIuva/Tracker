//
//  TrackerPlaceholderCollectionViewCell.swift
//  Tracker
//
//  Created by big stepper on 09/10/2024.
//

import UIKit


final class TrackerPlaceholderCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Singletone
    
    static let reuseIdentifier: String = "TrackerPlaceholderCollectionViewCell"
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Properties
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "dizzy")
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    //MARK: - UI Methods
    
    private func layoutCell() {
        addSubviews(placeholderImageView, placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor,
                                                  constant: 8),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
