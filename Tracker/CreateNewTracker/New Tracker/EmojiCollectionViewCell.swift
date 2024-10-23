//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by big stepper on 22/10/2024.
//

import UIKit


final class EmojiCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Reuse identifier
    
    static let reuseIdentifier: String = "EmojiCollectionViewCell"
    
    //MARK: - UI properties
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var bodyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: - UI methods
    
    private func layoutCell() {
        addSubview(bodyView)
        bodyView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            bodyView.heightAnchor.constraint(equalToConstant: 52),
            bodyView.widthAnchor.constraint(equalToConstant: 52),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: bodyView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: bodyView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    //MARK: - Methods
    
    func setupCell(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    func setSelected(_ isSelected: Bool) {
        bodyView.backgroundColor = isSelected ? .ypGray : .clear
    }
}
