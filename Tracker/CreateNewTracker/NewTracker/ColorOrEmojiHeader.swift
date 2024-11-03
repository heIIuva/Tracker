//
//  Untitled.swift
//  Tracker
//
//  Created by big stepper on 22/10/2024.
//

import UIKit


final class ColorOrEmojiHeader: UICollectionReusableView {
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Reuse identifier
    
    static let reuseIdentifier: String = "ColorOrEmojiHeader"
    
    //MARK: - UI properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    //MARK: - UI methods
    
    private func layoutHeader() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
        ])
    }
    
    //MARK: - Methods
    
    func configureHeader(text: String) {
        self.titleLabel.text = text
    }
}
