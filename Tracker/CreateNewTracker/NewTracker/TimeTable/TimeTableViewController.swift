//
//  TimeTableViewController.swift
//  Tracker
//
//  Created by big stepper on 14/10/2024.
//

import UIKit


final class TimeTableViewController: UIViewController {
    
    //MARK: - Init
    
    init(delegate: TimeTableViewControllerDelegate? = nil, timeTable: Set<Weekday>) {
        self.delegate = delegate
        self.timeTable = timeTable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI properties
    
    private lazy var doneButton: UIButton = {
       let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .label
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.systemBackground, for: .normal)
        button.setTitle(
            NSLocalizedString("done", comment: ""),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(doneButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypDarkGray
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TimeTableCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        return tableView
    }()
    
    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = .ypBlue
        daySwitch.addTarget(self,
                            action: #selector(switchToggled),
                            for: .touchDown)
        return daySwitch
    }()
    
    //MARK: - Properties
    
    weak var delegate: TimeTableViewControllerDelegate?
    
    private var timeTable: Set<Weekday> = []
    
    private let cellReuseIdentifier = TimeTableCell.reuseIdentifier
    
    private let days = Weekday.allCases
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI methods
    
    private func setupUI() {
        title = NSLocalizedString("timetable", comment: "")
        view.backgroundColor = .systemBackground
        view.addSubviews(tableView, doneButton)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                              constant: 541),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            timeTable.insert(days[sender.tag])
        } else {
            timeTable.remove(days[sender.tag])
        }
    }
    
    @objc private func doneButtonTapped() {
        delegate?.timeTable(timeTable)
        dismiss(animated: true)
    }
}

//MARK: - Extensions

extension TimeTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier,
                                                       for: indexPath) as? TimeTableCell else { return UITableViewCell() }
        
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.addTarget(self,
                           action: #selector(switchToggled),
                           for: .valueChanged)
        daySwitch.tag = indexPath.row
        daySwitch.isOn = timeTable.contains(days[indexPath.row]) ? true : false
        
        cell.setupCell(text: days[indexPath.row].weekday, accessoryView: daySwitch)
        
        cell.selectionStyle = .none
        if indexPath.row == days.count - 1 {
            cell.separatorInset = .init(top: 0,
                                        left: 0,
                                        bottom: 0,
                                        right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner,
                                        .layerMinXMaxYCorner]
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        return cell
    }
}

extension TimeTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

