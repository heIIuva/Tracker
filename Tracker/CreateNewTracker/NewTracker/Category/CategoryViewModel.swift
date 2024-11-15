//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by big stepper on 14/11/2024.
//

import Foundation


protocol CategoryViewModelProtocol: AnyObject {
    var onCategoriesTableChange: ((TrackerCategory) -> Void)? { get set }
    var onDoneButtonStateChange: ((Bool) -> Void)? { get set }
    var presentingAlert: ((Bool) -> Void)? { get set }
    func categories() -> [TrackerCategory]
    func setCategory(category: TrackerCategory)
    func tryToAddCategory()
    func deleteCategory(category: TrackerCategory)
    func setupAlertViewModel(viewModel: AlertModel)
    func showAlert()
    func seletectedCategory(indexPath: IndexPath)
    func isSelected(indexPath: IndexPath) -> Bool
    func doneButtonTapped()
}


final class CategoryViewModel: CategoryViewModelProtocol {
    
    //MARK: - Init
    
    init(
        alertPresenter: AlertPresenterProtocol,
        dataProvider: DataProviderProtocol,
        selectedCategory: String?
    ) {
        self.alertPresenter = alertPresenter
        self.dataProvider = dataProvider
        self.selectedCategory = selectedCategory
    }
    
    //MARK: - Properties
    
    weak var delegate: CategoryViewModelDelegate?
    
    var onCategoriesTableChange: ((TrackerCategory) -> Void)?
    var onDoneButtonStateChange: ((Bool) -> Void)?
    var presentingAlert: ((Bool) -> Void)?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var dataProvider: DataProviderProtocol?
    private var selectedCategory: String?
    private var newCategory: TrackerCategory?
    private var alertViewModel: AlertModel?
    
    //MARK: - Methods
    
    func categories() -> [TrackerCategory] {
        print("called categories method from viewmodel")
        return dataProvider?.getCategories() ?? []
    }
    
    func setCategory(category: TrackerCategory) {
        self.newCategory = category
    }
    
    func tryToAddCategory() {
        guard
            let newCategory,
            сategoryAlreadyExists(category: newCategory) == false
        else {
            showAlert()
            return
        }
        
        dataProvider?.addCategory(category: newCategory)
    }
    
    func deleteCategory(category: TrackerCategory) {
        dataProvider?.deleteCategory(category: category)
    }
    
    func setupAlertViewModel(viewModel: AlertModel) {
        self.alertViewModel = viewModel
    }
    
    func showAlert() {
        guard let alertViewModel else { return }
        alertPresenter?.showAlert(result: alertViewModel)
    }
    
    func seletectedCategory(indexPath: IndexPath) {
        let category = categories()[indexPath.row]
        self.selectedCategory = category.title
    }
    
    func isSelected(indexPath: IndexPath) -> Bool {
        categories()[indexPath.row].title == selectedCategory
    }
    
    func doneButtonTapped() {
        delegate?.category(selectedCategory ?? "")
    }
    
    private func сategoryAlreadyExists(category: TrackerCategory) -> Bool {
        categories().contains(where: { $0.title == category.title })
    }
}
