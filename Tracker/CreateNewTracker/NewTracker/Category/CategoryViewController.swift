//
//  CategoryViewController.swift
//  Tracker
//
//  Created by big stepper on 14/10/2024.
//

import UIKit


final class CategoryViewController: UIViewController {
    
    //MARK: - Init
    
    init(
        viewModel: CategoryViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI properties
    
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    //MARK: - Properties
    
    private var viewModel: CategoryViewModelProtocol
    
    private let placeholder = Placeholder.shared
    
    private var categories: [TrackerCategory]?
        
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categories = viewModel.categories()
        setupUI()
        bind()
    }
    
    //MARK: - Methods
    
    private func setupUI() {
        title = "Расписание"
        view.backgroundColor = .white
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
    
    private func bind() {
        viewModel.onCategoriesTableChange = { [weak self] isChanged in
            
        }
        
        viewModel.onDoneButtonStateChange = { [weak self] isChanged in
            
        }
        
        viewModel.presentingAlert = { [weak self] isPresenting in
            
        }
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let categories, !categories.isEmpty else {
                placeholder.showPlaceholder(image: .dizzy,
                                             text: "Привычки и события можно объединить по смыслу",
                                             view: self.view)
            return 0
        }
        
        placeholder.removePlaceholder()
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = .ypGray.withAlphaComponent(0.3)
        
        if viewModel.isSelected(indexPath: indexPath) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row == 0 {
            cell.separatorInset = .init(top: 0,
                                        left: 0,
                                        bottom: 0,
                                        right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        viewModel.seletectedCategory(indexPath: indexPath)
    }
}

//MARK: - UITextFieldDelegate
extension CategoryViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        viewModel.setCategory(
            category: TrackerCategory(
                title: text,
                trackers: []
            )
        )
    }
}
