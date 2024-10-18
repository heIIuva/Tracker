//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by big stepper on 08/10/2024.
//

import UIKit


final class TrackerCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Reuse identifier
    
    static let reuseIdentifier: String = "TrackerCollectionViewCell"
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI properties
    
    private lazy var bodyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.alpha = 0.3
        return view
    }()
    
    private lazy var trackerlabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var daysLeftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var completeTrackerButton: UIButton = {
        let button = UIButton()
        button.addTarget(self,
                         action: #selector(completeTrackerButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        return button
    }()
    
    //MARK: - Properties
    
    private var isCompleted: Bool = false
    private var counter: Int = 0
    
    //MARK: - Methods
    
    private func layoutCell() {
        bodyView.addSubviews(emojiView, emojiLabel, trackerlabel)
        addSubviews(bodyView, completeTrackerButton, daysLeftLabel)
        
        NSLayoutConstraint.activate([
            bodyView.heightAnchor.constraint(equalToConstant: 90),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: bodyView.topAnchor, constant: 12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            trackerlabel.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor,
                                                  constant: 12),
            trackerlabel.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor,
                                                   constant: -12),
            trackerlabel.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor,
                                                 constant: -12),
            
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            completeTrackerButton.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            
            daysLeftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            daysLeftLabel.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 16)
        ])
    }
    
    func setupCell(trackers: [Tracker], indexPath: IndexPath, isCompleted: Bool, counter: Int) {
        self.bodyView.backgroundColor = trackers[indexPath.row].color
        self.emojiLabel.text = trackers[indexPath.row].emoji
        self.trackerlabel.text = trackers[indexPath.row].name
        self.completeTrackerButton.backgroundColor = trackers[indexPath.row].color
        self.isCompleted = isCompleted
        self.counter = counter
    }
    
    //MARK: - Obj-C methods
    
    @objc private func completeTrackerButtonTapped() {
        print("completed")
    }
}
