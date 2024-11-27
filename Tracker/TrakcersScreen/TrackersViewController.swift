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


protocol FilterDelegate: AnyObject {
    func updateFilter(filter: Filter)
    func allTrackersFilter()
    func trackersForTodayFilter()
    func completedTrackersFilter()
    func incompletedTrackersFilter()
}

final class TrackersViewController: UIViewController {
    
    //MARK: - UI Properties
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("tracker", comment: "")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("searchbarplaceholder",
                                                                   comment: "")
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .systemBackground
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = .current
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlue
        button.setTitleColor(.systemBackground, for: .normal)
        button.setTitle(NSLocalizedString("filtertitle", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
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
    
    private let analyticsService = AnalyticsService()
    
    private var alertPresenter: AlertPresenterProtocol?
    
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
    
    private var currentFilter: Filter?
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        configureCollectionView()
        configureFilterButton()
        
        let dataProvider = DataProvider(
            categoryStore: TrackerCategoryStore(),
            recordStore: TrackerRecordStore()
        )
        dataProvider.delegate = self
        self.dataProvider = dataProvider
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
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
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureFilterButton() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -16),
            filterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 131),
            filterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -131),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func update() {
        categories = dataProvider?.getCategories() ?? []
        visibleCategories = categories
        datePickerUpdated(datePicker)
    }
    
    //MARK: - Methods
    
    private func isCompleted(_ tracker: Tracker) -> Bool {
        completedTrackers.contains { record in
            let daysMatch = Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
            return record.id == tracker.id && daysMatch
        }
    }
    
    func isPinned(_ tracker: UUID) -> Bool {
        let pinnedCategory = visibleCategories.first(where: { $0.title == NSLocalizedString("pinned", comment: "") })
        
        let pinnedTrackers = pinnedCategory?.trackers ?? []
        
        if pinnedTrackers.contains(where: { $0.id == tracker }) {
            return true
        } else {
            return false
        }
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
        analyticsService.trackEvent("tap", ["screen": "TrackerVC", "item": "create tracker"])
        
        let addTrackerVC = TrackerCreationViewController()
        addTrackerVC.delegate = self
        present(UINavigationController(rootViewController: addTrackerVC), animated: true)
    }
    
    @objc private func didTapFilterButton() {
        analyticsService.trackEvent("tap", ["screen": "TrackerVC", "item": "filter tracker"])
        
        let viewModel = FilterViewModel(selectedFilter: self.currentFilter)
        viewModel.delegate = self
        
        let filterVC = FilterViewController(
            viewModel: viewModel
            )
        
        let filterNC = UINavigationController(rootViewController: filterVC)
        
        filterNC.modalPresentationStyle = .popover
        present(filterNC, animated: true)
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
        analyticsService.trackEvent("tap", ["screen": "TrackerVC", "item": "searchbar"])
        
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
                                             text: NSLocalizedString("emptysearchresults",
                                                                     comment: ""),
                                             view: self.view)
            case false:
                placeholder.showPlaceholder(image: .dizzy,
                                            text: NSLocalizedString("trackerplaceholder",
                                                                    comment: ""),
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
        
        let trackerId = visibleCategories[indexPath.section].trackers[indexPath.row].id
        
        let isCompleted = completedTrackers.contains(where: {
            $0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id &&
            calendar.numberOfDaysBetween($0.date, and: currentDate) == 0})
        let counter = completedTrackers.filter({$0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id}).count
        
        cell.setupCell(trackers: visibleCategories[indexPath.section].trackers,
                       indexPath: indexPath,
                       isCompleted: isCompleted,
                       counter: counter,
                       isPinned: isPinned(trackerId))
        
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard let indexPath = indexPaths.first else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        
        let category = visibleCategories[indexPath.section]
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let pinTitle = cell.isCellPinned() ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: "")
        let pinImage = cell.isCellPinned() ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            let pin = UIAction(
                title: pinTitle,
                image:  pinImage
            ) { _ in
                self?.dataProvider?.togglePinTracker(tracker.id)
                self?.update()
                }
            let edit = UIAction(
                title: NSLocalizedString("edit", comment: ""),
                image: UIImage(systemName: "pencil")
            ) { _ in
                self?.analyticsService.trackEvent(
                    "tap",
                    ["screen": "TrackerVC", "item": "edit tracker"]
                )
                
                let habitOrEventVC = NewHabitOrEventViewController(
                    nibName: nil,
                    bundle: nil,
                    delegate: self ?? TrackersViewController(),
                    isHabit: self?.visibleCategories[indexPath.section].trackers[indexPath.row].timeTable != [],
                    dataProvider: DataProvider(
                        categoryStore: TrackerCategoryStore(),
                        recordStore: TrackerRecordStore()
                    ),
                    mode: .edit,
                    tracker: tracker,
                    category: category
                )
                let habitOrEventNC = UINavigationController(rootViewController: habitOrEventVC)
                self?.present(habitOrEventNC, animated: true)
            }
            let delete = UIAction(
                title: NSLocalizedString("delete", comment: ""),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.analyticsService.trackEvent(
                    "tap",
                    ["screen": "TrackerVC",
                     "item": "delete tracker"]
                )
                
                let alertModel = AlertModel(
                    message: NSLocalizedString("trackeralertmessage", comment: ""),
                    button: NSLocalizedString("delete", comment: ""),
                    completion: {
                        self?.analyticsService.trackEvent(
                            "tap",
                            ["screen": "TrackerVC",
                             "item": "deleted tracker"]
                        )
                        
                        self?.dataProvider?.deleteTracker(tracker)
                        self?.update()
                    },
                    secondButton: NSLocalizedString("cancel", comment: ""),
                    secondCompletion: {
                        self?.analyticsService.trackEvent(
                            "tap",
                            ["screen": "TrackerVC",
                             "item": "reconsidered deleting tracker"]
                        )
                    }
                )
                self?.alertPresenter?.showAlert(result: alertModel)
            }
            return UIMenu(title: "", children: [pin, edit, delete])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        let preview = UITargetedPreview(
            view: cell.preview(),
            parameters: parameters
        )
        return preview
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        let preview = UITargetedPreview(
            view: cell.preview(),
            parameters: parameters
        )
        return preview
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
extension TrackersViewController: TrackerCreationDelegate, NewTrackerVCDelegate {
    
    func reloadCollectionView() {
        categories = dataProvider?.getCategories() ?? []
        collectionView.reloadData()
        datePickerUpdated(datePicker)
    }
}

//MARK: - DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func updateCategories(categories: [TrackerCategory]) {
        self.categories = categories
        collectionView.reloadData()
        datePickerUpdated(datePicker)
    }
    
    func updateRecords(records: Set<TrackerRecord>) {
        self.completedTrackers = records
    }
}

//MARK: - FilterDelegate
extension TrackersViewController: FilterDelegate {
    func updateFilter(filter: Filter) {
        self.currentFilter = filter
    }
    
    func allTrackersFilter() {
        self.visibleCategories = dataProvider?.getCategories() ?? []
        datePickerUpdated(datePicker)
    }
    
    func trackersForTodayFilter() {
        datePicker.date = Date()
        datePickerUpdated(datePicker)
    }
    
    func completedTrackersFilter() {
        
        datePickerUpdated(datePicker)
        
        var completed: [TrackerCategory] = []
        for categoryIndex in 0..<visibleCategories.count {
            var trackers: [Tracker] = []
            for trackerIndex in 0..<visibleCategories[categoryIndex].trackers.count {
                if isCompleted(visibleCategories[categoryIndex].trackers[trackerIndex]) {
                    if let index = completed.firstIndex(where: {$0.title == visibleCategories[categoryIndex].title}) {
                        trackers.append(visibleCategories[categoryIndex].trackers[trackerIndex])
                        for tracker in completed[index].trackers {
                            trackers.append(tracker)
                        }
                        let newCategory = TrackerCategory(title: completed[index].title, trackers: trackers)
                        completed[index] = newCategory
                    } else {
                        let newCategory = TrackerCategory(title: visibleCategories[categoryIndex].title, trackers: [visibleCategories[categoryIndex].trackers[trackerIndex]])
                        completed.append(newCategory)
                    }
                }
            }
        }
        visibleCategories = completed
        collectionView.reloadData()
    }
    
    func incompletedTrackersFilter() {
        
        datePickerUpdated(datePicker)
        
        var incompleted: [TrackerCategory] = []
        for categoryIndex in 0..<visibleCategories.count {
            var trackers: [Tracker] = []
            for trackerIndex in 0..<visibleCategories[categoryIndex].trackers.count {
                if !isCompleted(visibleCategories[categoryIndex].trackers[trackerIndex]) {
                    if let index = incompleted.firstIndex(where: {$0.title == visibleCategories[categoryIndex].title}) {
                        trackers.append(visibleCategories[categoryIndex].trackers[trackerIndex])
                        for tracker in incompleted[index].trackers {
                            trackers.append(tracker)
                        }
                        let newCategory = TrackerCategory(title: incompleted[index].title, trackers: trackers)
                        incompleted[index] = newCategory
                    } else {
                        let newCategory = TrackerCategory(title: visibleCategories[categoryIndex].title, trackers: [visibleCategories[categoryIndex].trackers[trackerIndex]])
                        incompleted.append(newCategory)
                    }
                }
            }
        }
        visibleCategories = incompleted
        collectionView.reloadData()
    }
}

