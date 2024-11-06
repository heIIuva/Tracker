//
//  TrackerViewController.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit


protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapCompleteTrackerButton(isCompleted: Bool, id: UUID, completion: @escaping () -> Void)
}


protocol TrackerCreationDelegate: AnyObject {
    func reloadCollectionView()
}


final class TrackersViewController: UIViewController {
    
    //MARK: - UI Properties
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        datePicker.addTarget(self, action: #selector(datePickerUpdated), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var addTrackerButton: UIButton = {
        guard let image = UIImage(systemName: "plus") else { return UIButton() }
        
        let button = UIButton.systemButton(with: image,
                                           target: self,
                                           action: #selector(addTrackerButtonTapped))
        button.tintColor = .label
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.register(TrackerCollectionViewCell.self,
                            forCellWithReuseIdentifier: trackerCellReuseIdentifier)
        collection.register(TrackerCollectionViewHeader.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: trackerHeaderReuseIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isScrollEnabled = true
        collection.backgroundColor = .systemBackground
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    //MARK: - Properties
    
    private var dataProvider: DataProviderProtocol?
        
    private let trackerCellReuseIdentifier = TrackerCollectionViewCell.reuseIdentifier
    private let trackerHeaderReuseIdentifier = TrackerCollectionViewHeader.reuseIdentifier
    private let placeholder = Placeholder.shared
    
    private let dateFormatter = DateFormatter.dateFormatter
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    
    private var isSearch: Bool = false
    
    private var currentDate = Date()
    private let calendar = Calendar.current
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        configureCollectionView()
        
        let dataProvider = DataProvider(
            categoryStore: TrackerCategoryStore(),
            recordStore: TrackerRecordStore()
        )
        dataProvider.delegate = self
        self.dataProvider = dataProvider
        
        self.categories = dataProvider.getCategories()
        self.completedTrackers = dataProvider.getRecords()
        
        datePickerUpdated(datePicker)
    }
    
    //MARK: UI methods
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.tintColor = .label
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = trackersLabel.text
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 236),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    //MARK: - Obj-C Methods
    
    @objc private func datePickerUpdated(_ sender: UIDatePicker) {
        currentDate = calendar.date(from: sender.date)
        let weekDay = calendar.component(.weekday, from: currentDate)
        var visibleCategories: [TrackerCategory] = []
        categories.forEach { category in
            var trackers: [Tracker] = []
            category.trackers.forEach { tracker in
                guard tracker.timeTable.isEmpty,
                      !completedTrackers.contains(where: {
                          $0.id == tracker.id &&
                          $0.date != currentDate})
                else {
                    tracker.timeTable.forEach { timeTable in
                        if timeTable.int == weekDay {
                            trackers.append(tracker)
                        }
                    }
                    return
                }
                trackers.append(tracker)
            }
            let visibleCategory: TrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
            if !visibleCategory.trackers.isEmpty {
                visibleCategories.append(visibleCategory)
            }
        }
        self.visibleCategories = visibleCategories
        collectionView.reloadData()
    }
    
    @objc private func addTrackerButtonTapped() {
        let addTrackerVC = TrackerCreationViewController()
        addTrackerVC.delegate = self
        present(UINavigationController(rootViewController: addTrackerVC), animated: true)
    }
}


//MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercased(),
              searchText.count > 2 else { return }
        
        
    }
}

//MARK: - UISearchControllerDelegate
extension TrackersViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearch = true
        collectionView.reloadData()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        datePickerUpdated(datePicker)
        isSearch = false
        collectionView.reloadData()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let header: UICollectionReusableView
        
        if #available(iOS 18.0, *) {
            return CGSize(width: collectionView.bounds.width - 56, height: 18)
        } else {
            header = self.collectionView(collectionView,
                                                 viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                                 at: indexPath)
        }
        
        
        
        return header.systemLayoutSizeFitting(CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard !visibleCategories.isEmpty else {
            switch isSearch {
            case true:
                placeholder.showPlaceholder(image: .error,
                                             text: "Ничего не найдено",
                                             view: self.view)
            case false:
                placeholder.showPlaceholder(image: .dizzy,
                                             text: "Что будем отслеживать?",
                                             view: self.view)
            }
            return 0
        }
        
        placeholder.removePlaceholder()
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: trackerCellReuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let isCompleted = completedTrackers.contains(where: {
            $0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id &&
            calendar.numberOfDaysBetween($0.date, and: currentDate) == 0})
        let counter = completedTrackers.filter({$0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id}).count
        
        cell.setupCell(trackers: visibleCategories[indexPath.section].trackers,
                       indexPath: indexPath,
                       isCompleted: isCompleted,
                       counter: counter)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: trackerHeaderReuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewHeader else { return UICollectionReusableView() }
        
        header.configureHeader(categories: visibleCategories, indexPath: indexPath)
        
        return header
    }
}

//MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteTrackerButton(isCompleted: Bool, id: UUID, completion: @escaping () -> Void) {
        let record = TrackerRecord(id: id, date: currentDate)
        switch isCompleted {
        case true:
            guard let days = calendar.numberOfDaysBetween(currentDate), days >= 0 else { return }
            dataProvider?.addRecord(record: record)
        case false:
            dataProvider?.deleteRecord(record: record)
        }
        completion()
    }
}

//MARK: - TrackerCreationDelegate
extension TrackersViewController: TrackerCreationDelegate {
    
    func reloadCollectionView() {
        visibleCategories = categories
        collectionView.reloadData()
        datePickerUpdated(datePicker)
    }
}

//MARK: - DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func updateCategories(categories: [TrackerCategory]) {
        self.categories = categories
        collectionView.reloadData()
    }
    
    func updateRecords(records: Set<TrackerRecord>) {
        self.completedTrackers = records
    }
}
