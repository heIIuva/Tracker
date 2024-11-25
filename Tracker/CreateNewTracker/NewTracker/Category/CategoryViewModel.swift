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
    func deleteCategory(category: String)
//    func showAlert(viewModel: AlertModel)
    func seletectedCategory(indexPath: IndexPath)
    func isSelected(indexPath: IndexPath) -> Bool
    func doneButtonTapped()
    func setMode(_ mode: Mode)
}


enum Mode {
    case create
    case edit(String)
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
    private var mode: Mode?
    
    //MARK: - Methods
    
    func categories() -> [TrackerCategory] {
        dataProvider?.getCategories() ?? []
    }
    
    func setCategory(category: TrackerCategory) {
        guard
            !сategoryAlreadyExists(category: category.title)
        else {
            return
        }
        
        self.newCategory = category
    }
    
    func deleteCategory(category: String) {
        dataProvider?.deleteCategory(category: category)
        onCategoriesUpdate?()
        if category == selectedCategory {
            delegate?.category("")
        }
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
        switch mode {
        case .create:
            tryToAddCategory()
        case .edit(let oldCategory):
            tryToEditCategory(oldCategory: oldCategory)
        default :
            break
        }
        
        onCategoriesUpdate?()
        onDoneButtonStateChange?(false)
    }
    
    func setMode(_ mode: Mode) {
        self.mode = mode
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
    
    private func tryToEditCategory(oldCategory: String) {
        guard
            let newCategory,
            сategoryAlreadyExists(category: newCategory.title) == false
        else { return }
        print("category edited successfully")
        dataProvider?.editCategory(oldCategory, to: newCategory.title)
    }
    
    private func tryToAddCategory() {
        guard
            let newCategory,
            сategoryAlreadyExists(category: newCategory.title) == false
        else { return }
        dataProvider?.addCategory(category: newCategory)
    }
}
