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
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var trackerCounterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var completeTrackerButton: UIButton = {
        let button = UIButton()
        button.addTarget(self,
                         action: #selector(completeTrackerButtonTapped),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.tintColor = .systemBackground
        return button
    }()
    
    //MARK: - Properties
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var id: UUID? = nil
    private var isCompleted: Bool = false
    private var counter: Int = 0
    
    //MARK: - Methods
    
    private func layoutCell() {
        bodyView.addSubviews(emojiView, emojiLabel, trackerLabel)
        addSubviews(bodyView, completeTrackerButton, trackerCounterLabel)
        
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
            
            trackerLabel.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor,
                                                  constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor,
                                                   constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor,
                                                 constant: -12),
            
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            completeTrackerButton.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            
            trackerCounterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            trackerCounterLabel.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 16)
        ])
    }
    
    private func updateTrackerCounterLabel(isCompleted: Bool) {
        counter = isCompleted ? counter + 1 : counter - 1
        trackerCounterLabel.text = counter.string()
    }
    
    private func updateCompleteTrackerButton(isCompleted: Bool) {
        self.isCompleted = isCompleted
        switch isCompleted {
        case true:
            completeTrackerButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeTrackerButton.backgroundColor = bodyView.backgroundColor?.withAlphaComponent(0.3)
        case false:
            completeTrackerButton.setImage(UIImage(systemName: "plus"), for:  .normal)
            completeTrackerButton.backgroundColor = bodyView.backgroundColor
        }
    }
    
    func setupCell(trackers: [Tracker], indexPath: IndexPath, isCompleted: Bool, counter: Int) {
        self.bodyView.backgroundColor = trackers[indexPath.row].color
        self.emojiLabel.text = trackers[indexPath.row].emoji
        self.trackerLabel.text = trackers[indexPath.row].name
        self.trackerCounterLabel.text = counter.string()
        self.completeTrackerButton.backgroundColor = trackers[indexPath.row].color
        self.id = trackers[indexPath.row].id
        
        self.isCompleted = isCompleted
        self.counter = counter
        
        updateCompleteTrackerButton(isCompleted: isCompleted)
    }
    
    //MARK: - Obj-C methods
    
    @objc private func completeTrackerButtonTapped() {
        guard let id else { return }
        
        delegate?.didTapCompleteTrackerButton(isCompleted: !isCompleted,
                                              id: id) { [weak self] in
            guard let self else { return }
            
            updateCompleteTrackerButton(isCompleted: !isCompleted)
            updateTrackerCounterLabel(isCompleted: isCompleted)
        }
    }
}
