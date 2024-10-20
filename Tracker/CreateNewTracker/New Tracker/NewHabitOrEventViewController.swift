//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by big stepper on 09/10/2024.
//

import UIKit


protocol TimeTableViewControllerDelegate: AnyObject {
    func timeTable(_ timeTable: Set<Weekday>)
}


protocol CategoryTableViewControllerDelegate: AnyObject { }


final class NewHabitOrEventViewController: UIViewController {
    
    //MARK: - Init
    
    init(
        nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         options: [String]
    ) {
        self.cellTitle = options
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - UI properties
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addPaddingToTextField()
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .ypGray.withAlphaComponent(0.3)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .black
        textField.placeholder = "Введите название трекера"
        textField.delegate = self
        return textField
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.addTarget(self,
                         action: #selector(didTapCancelButton),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .ypDarkGray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.setTitle("Создать", for: .normal)
        button.addTarget(self,
                         action: #selector(didTapCreateButton),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "tableViewCell")
        return tableView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var textFieldStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [textField, warningLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()
    
    //MARK: - Properties
    
    weak var delegate: NewTrackerVCDelegate?
    
    private var categories = TrackerStorage.shared
    
    private var cellTitle: [String]
    
    private var trackerName: String = ""
    private var timeTable: Set<Weekday> = []
    
    //TODO: - add category, color, emoji selection sprint 15
    private var categoryName: String = "Важное"
    private var selectedColor: UIColor = .ypRed
    private var selectedEmoji: String = "🤨"

    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI methods
    
    private func layoutButtonsInStackView() {
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 166)
        ])
    }
    
    func setupUI() {
        self.title = cellTitle.count == 2 ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .white
        view.addSubviews(scrollView,  buttonsStackView)
        scrollView.addSubviews(textFieldStackView, tableView)
        
        layoutButtonsInStackView()
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                    constant: 24),
            
            textField.heightAnchor.constraint(equalToConstant: 75),

            warningLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * cellTitle.count)),
            tableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    //MARK: - Methods
    
    private func enableCreateButton() {
        createButton.isEnabled = true
        createButton.backgroundColor = .black
    }
    
    private func checkIfAllFieldsAreFilled() {
        //TODO: - category, colors, emoji check
        guard !trackerName.isEmpty, !timeTable.isEmpty else { return }
        
        enableCreateButton()
    }
    
    //TODO: - category, color, emoji sprint 15
    private func createNewTracker() {
        let tracker = Tracker(id: UUID(),
                              name: self.trackerName,
                              color: self.selectedColor,
                              emoji: self.selectedEmoji,
                              timeTable: Array(self.timeTable))
        
        if let categoryIndex = categories.categoriesStorage.firstIndex(where: { $0.title.lowercased() == self.categoryName.lowercased() }) {
            var trackersInCategory = categories.categoriesStorage[categoryIndex].trackers
            trackersInCategory.append(tracker)
            let categoryForTracker = categories.categoriesStorage[categoryIndex].title
            let updatedCategory = TrackerCategory(title: categoryForTracker,
                                              trackers: trackersInCategory)
            categories.categoriesStorage[categoryIndex] = updatedCategory
            print("new tracker added to an existing category \(categories.categoriesStorage)")
        } else {
            let newCategory = TrackerCategory(title: self.categoryName, trackers: [tracker])
            categories.categoriesStorage.append(newCategory)
            print("new tracker added to a new category \(categories.categoriesStorage)")
        }
    }
    
    //MARK: - Obj-C methods
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        createNewTracker()
        dismiss(animated: true)
        delegate?.reloadCollectionView()
    }
}

//MARK: - Extensions

extension NewHabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableViewCell")
        
        cell.backgroundColor = .ypGray.withAlphaComponent(0.3)
        cell.accessoryType = .disclosureIndicator
        
        cell.detailTextLabel?.textColor = .ypDarkGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        switch indexPath.row {
        case 0:
            //TODO: - Category VC
            cell.textLabel?.text = cellTitle[0]
        case 1:
            cell.textLabel?.text = cellTitle[1]
            cell.detailTextLabel?.text = timeTable.count == 7 ? "Каждый день" : timeTable.map { $0.shortened }.joined(separator: ", ")
        default:
            break
        }
        
        cell.selectionStyle = .none
        if indexPath.row == cellTitle.count - 1 {
            cell.separatorInset = .init(top: 0,
                                        left: 0,
                                        bottom: 0,
                                        right: .greatestFiniteMagnitude)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        return cell
    }
}


extension NewHabitOrEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //TODO: - Category View Controller sprint 15
            break
        case 1:
            let timeTableVC = UINavigationController(rootViewController: TimeTableViewController(delegate: self, timeTable: self.timeTable))
            self.present(timeTableVC, animated: true)
        default:
            break
        }
    }
}


extension NewHabitOrEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count < 38 && text.count > 0 {
            self.trackerName = text
            checkIfAllFieldsAreFilled()
            warningLabel.isHidden = true
        } else if text.count > 38 {
            warningLabel.isHidden = false
        }
    }
}


extension NewHabitOrEventViewController: TimeTableViewControllerDelegate {
    func timeTable(_ timeTable: Set<Weekday>) {
        self.timeTable = timeTable
        tableView.reloadData()
        checkIfAllFieldsAreFilled()
    }
}
