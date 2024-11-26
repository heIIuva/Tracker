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
        textField.placeholder = NSLocalizedString("categorytextfieldplaceholder", comment: "")
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
        button.setTitle(
            NSLocalizedString("done", comment: ""),
            for: .normal
        )
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
        button.setTitle(
            NSLocalizedString("addcategory", comment: ""),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(didTapAddCategoryButton),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Properties
    
    private var viewModel: CategoryViewModelProtocol
    private var alertPresenter: AlertPresenterProtocol?
    
    private let placeholder = Placeholder.shared
    
    private var categories: [TrackerCategory]?
        
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        self.categories = viewModel.categories()
        setupUI()
        bind()
        switchDoneButtonState(false)
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
        title = NSLocalizedString("category", comment: "")
        placeholder.showPlaceholder(
            image: .dizzy,
            text: NSLocalizedString("categoryplaceholder", comment: ""),
            view: view
        )
        doneButton.isHidden = true
        tableView.isHidden = true
        textField.isHidden = true
        addCategoryButton.isHidden = false
    }
    
    private func selectCategoryState() {
        title = NSLocalizedString("category", comment: "")
        addCategoryButton.isHidden = false
        doneButton.isHidden = true
        tableView.isHidden = false
        textField.isHidden = true
        placeholder.removePlaceholder()
    }
    
    private func addCategoryState() {
        title = NSLocalizedString("newcategory", comment: "")
        addCategoryButton.isHidden = true
        doneButton.isHidden = false
        tableView.isHidden = true
        textField.isHidden = false
        placeholder.removePlaceholder()
    }
    
    private func editingState() {
        title = NSLocalizedString("editcategory", comment: "")
        addCategoryButton.isHidden = true
        doneButton.isHidden = false
        tableView.isHidden = true
        textField.isHidden = false
        placeholder.removePlaceholder()
    }
    
    //MARK: - Binding methods
    
    private func switchDoneButtonState(_ isChanged: Bool) {
        doneButton.isEnabled = isChanged
        doneButton.backgroundColor = isChanged ? .black : .ypGray
    }
    
    private func updateTableView() {
        categories = viewModel.categories()
        tableView.reloadData()
    }
    
    //MARK: - Obj-C Methods
    
    @objc private func didTapAddCategoryButton() {
        addCategoryState()
        viewModel.setMode(.create)
    }
    
    @objc private func didTapDoneButton() {
        selectCategoryState()
        viewModel.doneButtonTapped()
        textField.text = nil
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
            DispatchQueue.main.async {
                self.OnboardingState()
            }
            return 0
        }
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
        self.dismiss(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard
            let cell = tableView.cellForRow(at: indexPath),
            let text = cell.textLabel?.text
        else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            
            let edit = UIAction(
                title: NSLocalizedString("edit", comment: ""),
                image: UIImage(systemName: "pencil")
            ) { _ in
                self?.editingState()
                self?.viewModel.setMode(.edit(text))
                self?.textField.text = text
            }
            
            let delete = UIAction(
                title: NSLocalizedString("delete", comment: ""),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                let alertModel = AlertModel(
                    message: NSLocalizedString("categoryalertmessage", comment: ""),
                    button: NSLocalizedString("delete", comment: ""),
                    completion: {
                        self?.viewModel.deleteCategory(category: text)
                    },
                    secondButton: NSLocalizedString("cancel", comment: ""),
                    secondCompletion: {}
                )
                self?.alertPresenter?.showAlert(result: alertModel)
            }
            
            return UIMenu(title: "", options: .displayInline, children: [edit, delete])
        }
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
        guard
            let text = textField.text,
            !text.isEmpty
        else { return }
        
        viewModel.setCategory(
            category: TrackerCategory(
                title: text,
                trackers: []
            )
        )
    }
}
