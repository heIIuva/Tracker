//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by big stepper on 22/10/2024.
//

import UIKit


final class ColorCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Reuse identfifier
    
    static let reuseIdentifier: String = "ColorCollectionViewCell"
    
    //MARK: UI properties
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var bodyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0
//        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: - UI methods
    
    private func layoutCell() {
        addSubview(bodyView)
        bodyView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            bodyView.heightAnchor.constraint(equalToConstant: 52),
            bodyView.widthAnchor.constraint(equalToConstant: 52),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: bodyView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: bodyView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    //MARK: - Methods
    
    func setupCell(with color: UIColor) {
        colorView.backgroundColor = color
        bodyView.layer.borderColor = color.cgColor
    }
    
    func setSelected(_ isSelected: Bool) {
        bodyView.layer.borderWidth = isSelected ? 3 : 0
    }
}
