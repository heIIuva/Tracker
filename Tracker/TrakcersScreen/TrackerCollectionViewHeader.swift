//
//  TrackerCollectionViewHeader.swift
//  Tracker
//
//  Created by big stepper on 12/10/2024.
//

import UIKit


final class TrackerCollectionViewHeader: UICollectionReusableView {
    
    //MARK: - Reuse identifier
    
    static let reuseIdentifier: String = "TrackerCollectionViewHeader"
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutHeader()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI properties
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    //MARK: - UI methods
    
    private func layoutHeader() {
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
        ])
    }
    
    //MARK: - Methods
    
    func configureHeader(categories: [TrackerCategory], indexPath: IndexPath) {
        title.text = categories[indexPath.section].title
    }
}
