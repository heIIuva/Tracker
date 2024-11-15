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
        tableView.allowsMultipleSelection = false
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Готово", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapDoneButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Добавить категорию", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapAddCategoryButton),
            for: .touchUpInside
        )
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
        view.backgroundColor = .white
        
        view.addSubviews(textField, tableView, addCategoryButton, doneButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -115),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -16),
            
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func bind() {
        viewModel.onDoneButtonStateChange = { [weak self] isChanged in
            guard let self else { return }
            self.switchDoneButtonState(isChanged)
        }
        
        viewModel.onCategoriesUpdate = { [weak self] in
            guard let self else { return }
            self.updateTableView()
        }
    }
    
    private func OnboardingState() {
        title = "Категория"
        placeholder.showPlaceholder(
            image: .dizzy,
            text: "Привычки и события можно объединить по смыслу",
            view: self.view
        )
        doneButton.isHidden = true
        tableView.isHidden = true
        textField.isHidden = true
        addCategoryButton.isHidden = false
    }
    
    private func selectCategoryState() {
        title = "Категория"
        addCategoryButton.isHidden = false
        doneButton.isHidden = true
        tableView.isHidden = false
        textField.isHidden = true
    }
    
    private func addCategoryState() {
        title = "Новая категория"
        addCategoryButton.isHidden = true
        doneButton.isHidden = false
        tableView.isHidden = true
        textField.isHidden = false
    }
    
    private func switchDoneButtonState(_ isChanged: Bool) {
        doneButton.isEnabled = isChanged
        doneButton.backgroundColor = isChanged ? .black : .ypGray
    }
    
    private func updateTableView() {
        categories = viewModel.categories()
        tableView.reloadData()
    }
    
    //MARK: - Obj-C Methods
    
    @objc func didTapAddCategoryButton() {
        addCategoryState()
    }
    
    @objc func didTapDoneButton() {
        selectCategoryState()
        viewModel.doneButtonTapped()
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard
            let categories,
            !categories.isEmpty
        else {
            OnboardingState()
            return 0
        }
        placeholder.removePlaceholder()
        selectCategoryState()
        return categories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let categories else { return UITableViewCell() }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = .ypGray.withAlphaComponent(0.3)
        cell.textLabel?.text = categories[indexPath.row].title
        cell.selectionStyle = .none
        
        if viewModel.isSelected(indexPath: indexPath) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row == categories.count - 1 {
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
        tableView.reloadData()
    }
    
    //TODO: - UIContextMenuConfiguration
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
        guard
            let text = textField.text,
            !viewModel.сategoryAlreadyExists(category: text)
        else { return }
        
        viewModel.setCategory(
            category: TrackerCategory(
                title: text,
                trackers: []
            )
        )
    }
}
