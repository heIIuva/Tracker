//
//  TrackerSrorage.swift
//  Tracker
//
//  Created by big stepper on 16/10/2024.
//

import Foundation


protocol DataProviderProtocol: AnyObject {
    func getCategories() -> [TrackerCategory]
    func addCategory(category: TrackerCategory)
    func addTrackerToCategory(tracker: Tracker, category: String)
    func getRecords() -> Set<TrackerRecord>
    func addRecord(record: TrackerRecord)
    func deleteRecord(record: TrackerRecord)
}


protocol DataProviderDelegate: AnyObject {
    func updateCategories(categories: [TrackerCategory])
    func updateRecords(records: Set<TrackerRecord>)
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
    func getCategories() -> [TrackerCategory] {
        guard let categories = categoryStore?.categories else { return [] }
        return categories
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
}

//MARK: - TrackerCategoryStoreDelegate
extension DataProvider: TrackerCategoryStoreDelegate {
    func didUpdateCategory() {
        delegate?.updateCategories(categories: getCategories())
    }
}

//MARK: - TrackerRecordStoreDelegate
extension DataProvider: TrackerRecordStoreDelegate {
    func didUpdateRecord() {
        delegate?.updateRecords(records: getRecords())
    }
}
