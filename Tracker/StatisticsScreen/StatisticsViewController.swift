//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit


final class StatisticsViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticsCell.self,
                           forCellReuseIdentifier: reuseIdentfier)
        return tableView
    }()
    
    private let placeholder = Placeholder.shared
    
    private let reuseIdentfier: String = StatisticsCell.reuseIdentifier
    
    private let statistics = [NSLocalizedString("completedtrackers", comment: "")]
    
    private var records: Set<TrackerRecord> = []
    
    private var dataProvider: DataProviderProtocol?
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataProvider = DataProvider(
            categoryStore: TrackerCategoryStore(),
            recordStore: TrackerRecordStore())
        self.dataProvider = dataProvider
                
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        records = dataProvider?.getRecords() ?? []
        tableView.reloadData()
    }
    
    //MARK: - Methods
    
    private func setupUI() {
        navigationItem.title = NSLocalizedString("stats", comment: "")
        navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

//MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard
            records.count > 0
        else {
            placeholder.showPlaceholder(
                image: .statsPlaceholder,
                text: NSLocalizedString("statisticsplaceholder", comment: ""),
                view: view)
            return 0
        }
        
        placeholder.removePlaceholder()
        return statistics.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentfier,
                for: indexPath
            ) as? StatisticsCell
        else {
            return UITableViewCell()
        }
        
        cell.configureCell(
            counter: records.count,
            title: statistics[indexPath.row]
        )
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}
