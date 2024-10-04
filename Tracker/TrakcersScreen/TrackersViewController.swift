//
//  TrackerViewController.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit


final class TrackersViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var trackersLabel: UILabel? = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchController: UISearchController? = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()
    
    private lazy var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "Ru-ru")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        datePicker.addTarget(self, action: #selector(datePickerUpdated), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var addTrackerButton: UIButton? = {
        guard let image = UIImage(systemName: "plus") else { return UIButton() }
        
        let button = UIButton.systemButton(with: image,
                                           target: self,
                                           action: #selector(addTrackerButtonTapped))
        button.tintColor = .black
        return button
    }()
    
    private lazy var trackersPlaceholderLabel: UILabel? = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackersPlaceholderImageView: UIImageView? = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var trackersPlaceholderStackView: UIStackView? = {
        guard let trackersPlaceholderLabel, let trackersPlaceholderImageView else { return UIStackView() }
        
        let stackView = UIStackView(arrangedSubviews: [trackersPlaceholderImageView, trackersPlaceholderLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureUI()
    }
    
    //MARK: UI methods
    
    private func configureNavigationBar() {
        guard let datePicker, let addTrackerButton, let trackersLabel else { return }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.searchController = searchController
        navigationItem.title = trackersLabel.text
    }
    
    private func configureUI() {
        guard let trackersPlaceholderStackView, let trackersPlaceholderImageView else { return }
        
        view.addSubview(trackersPlaceholderStackView)
        
        NSLayoutConstraint.activate([
            trackersPlaceholderStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersPlaceholderStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersPlaceholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            trackersPlaceholderImageView.heightAnchor.constraint(equalToConstant: 80),
            trackersPlaceholderImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    //MARK: - Obj-C Methods
    
    @objc private func datePickerUpdated() {
        
    }
    
    @objc private func addTrackerButtonTapped() {
        
    }
}

//MARK: - Extenions

extension TrackersViewController: UISearchControllerDelegate {
    
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("\(searchController.searchBar.text ?? "")")
    }
    
    
}
