//
//  TrackerSrorage.swift
//  Tracker
//
//  Created by big stepper on 16/10/2024.
//

import Foundation


protocol DataProviderProtocol: AnyObject {
    func getCategories(_ sender: Sender) -> [TrackerCategory]
    func addCategory(category: TrackerCategory)
    func addTrackerToCategory(tracker: Tracker, category: String)
    func deleteCategory(category: String)
    func getRecords() -> Set<TrackerRecord>
    func addRecord(record: TrackerRecord)
    func deleteRecord(record: TrackerRecord)
    func editCategory(_ category: String, to newCategory: String)
    func deleteTracker(_ tracker: Tracker)
    func editTracker(tracker: UUID, to newTracker: Tracker, with category: String)
    func togglePinTracker(_ tracker: UUID)
}


protocol DataProviderDelegate: AnyObject {
    func updateCategories(categories: [TrackerCategory])
    func updateRecords(records: Set<TrackerRecord>)
}


enum Sender {
    case trackerVC
    case categoryVC
}


final class DataProvider {
    
    //MARK: - Init
    
    init(
        categoryStore: TrackerCategoryStoreProtocol,
        recordStore: TrackerRecordStoreProtocol
    ) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        
        categoryStore.delegate = self
        recordStore.delegate = self
    }
    
    //MARK: - Properties
    
    weak var delegate: DataProviderDelegate?
    
    private let trackerStore = TrackerStore.shared
    private let categoryStore: TrackerCategoryStoreProtocol?
    private let recordStore: TrackerRecordStoreProtocol?
}

//MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    
    func getCategories(_ sender: Sender) -> [TrackerCategory] {
        switch sender {
        case .trackerVC:
            var sortedCategories = categoryStore?.categories ?? []
            guard
                let pinnedCategory = sortedCategories.first(where: { $0.title == NSLocalizedString("pinned", comment: "")})
            else {
                return categoryStore?.categories ?? []
            }
            sortedCategories.removeAll(where: { $0.title == NSLocalizedString("pinned", comment: "")})
            sortedCategories.insert(pinnedCategory, at: 0)
            return sortedCategories
        case .categoryVC:
            var categories = categoryStore?.categories ?? []
            categories.removeAll(where: { $0.title == NSLocalizedString("pinned", comment: "")})
            return categories
        }
    }
    
    func addCategory(category: TrackerCategory) {
        categoryStore?.addCategoryToCoreData(category)
    }
    
    func addTrackerToCategory(tracker: Tracker, category: String) {
        categoryStore?.addTrackerToCategory(tracker, category)
    }
    
    func getRecords() -> Set<TrackerRecord> {
        guard let records = recordStore?.records else { return [] }
        return records
    }
    
    func addRecord(record: TrackerRecord) {
        recordStore?.addRecord(record)
    }
    
    func deleteRecord(record: TrackerRecord) {
        recordStore?.deleteRecord(record)
    }
    
    func deleteCategory(category: String) {
        categoryStore?.deleteCategoryFromCoreData(category)
    }
    
    func editCategory(_ category: String, to newCategory: String) {
        categoryStore?.editCategory(category, to: newCategory)
    }
    
    func deleteTracker(_ tracker: Tracker) {
        trackerStore.deleteTrackerFromCoreData(tracker)
    }
    
    func editTracker(tracker: UUID, to newTracker: Tracker, with category: String) {
        trackerStore.editTracker(tracker: tracker, to: newTracker)
        categoryStore?.updateTrackerCategory(tracker, category)
    }
    
    func togglePinTracker(_ tracker: UUID) {
        let trackerCoreData = trackerStore.fetchTrackerFromCoreDataById(tracker)
        if trackerCoreData?.category?.title == NSLocalizedString("pinned", comment: "") {
            categoryStore?.unpinTracker(tracker)
        } else {
            categoryStore?.pinTracker(tracker, NSLocalizedString("pinned", comment: ""))
        }
    }
}

//MARK: - TrackerCategoryStoreDelegate
extension DataProvider: TrackerCategoryStoreDelegate {
    func didUpdateCategory() {
        delegate?.updateCategories(categories: getCategories(.trackerVC))
    }
}

//MARK: - TrackerRecordStoreDelegate
extension DataProvider: TrackerRecordStoreDelegate {
    func didUpdateRecord() {
        delegate?.updateRecords(records: getRecords())
    }
}
