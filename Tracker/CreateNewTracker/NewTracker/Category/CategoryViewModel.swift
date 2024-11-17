//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by big stepper on 14/11/2024.
//

import Foundation


protocol CategoryViewModelProtocol: AnyObject {
    var onDoneButtonStateChange: ((Bool) -> Void)? { get set }
    var onCategoriesUpdate: (() -> Void)? { get set }
    func categories() -> [TrackerCategory]
    func setCategory(category: TrackerCategory)
    func deleteCategory(category: TrackerCategory)
    func showAlert(viewModel: AlertModel)
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
    
    var onDoneButtonStateChange: ((Bool) -> Void)?
    var onCategoriesUpdate: (() -> Void)?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var dataProvider: DataProviderProtocol?
    private var selectedCategory: String?
    private var newCategory: TrackerCategory?
    private var alertViewModel: AlertModel?
    
    //MARK: - Methods
    
    func categories() -> [TrackerCategory] {
        return dataProvider?.getCategories() ?? []
    }
    
    func setCategory(category: TrackerCategory) {
        guard
            !сategoryAlreadyExists(category: category.title)
        else {
            return
        }
        
        self.newCategory = category
    }
    
    func deleteCategory(category: TrackerCategory) {
        dataProvider?.deleteCategory(category: category)
    }
    
    //MARK: - for UIContextMenuConfiguration
    func showAlert(viewModel: AlertModel) {
        guard let alertViewModel else { return }
        alertPresenter?.showAlert(result: alertViewModel)
    }
    
    func seletectedCategory(indexPath: IndexPath) {
        let category = categories()[indexPath.row]
        self.selectedCategory = category.title
        delegate?.category(category.title)
    }
    
    func isSelected(indexPath: IndexPath) -> Bool {
        categories()[indexPath.row].title == selectedCategory
    }
    
    func doneButtonTapped() {
        tryToAddCategory()
        onCategoriesUpdate?()
        onDoneButtonStateChange?(false)
    }
    
    private func сategoryAlreadyExists(category: String) -> Bool {
        guard
            !categories().contains(where: { $0.title == category })
        else {
            onDoneButtonStateChange?(false)
            return true
        }
        onDoneButtonStateChange?(true)
        return false
    }
    
    private func tryToAddCategory() {
        guard
            let newCategory,
            сategoryAlreadyExists(category: newCategory.title) == false
        else { return }
        dataProvider?.addCategory(category: newCategory)
    }
}
