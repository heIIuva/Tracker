//
//  TrackerSrorage.swift
//  Tracker
//
//  Created by big stepper on 16/10/2024.
//

import Foundation
//
//
//final class TrackerStorage {
//    
//    //MARK: - Singletone
//    
//    static let shared = TrackerStorage()
//    
//    private init(){}
//    
//    //MARK: - Properties
//    
//    private var categories: [TrackerCategory] = [TrackerCategory(title: "Mock",
//                                                                 trackers:
//                                                                  [Tracker(id: UUID(),
//                                                                           name: "firstTracker",
//                                                                           color: .ypBlue,
//                                                                           emoji: "😄",
//                                                                           timeTable: [.monday]),
//                                                                   Tracker(id: UUID(),
//                                                                           name: "secondTracker",
//                                                                           color: .ypRed,
//                                                                           emoji: "😊",
//                                                                           timeTable: [.friday])
//                                                                 ]),
//      
//  ]
//    
//    //MARK: - Storage
//    
//    private let storage = DispatchQueue(label: "trackerStorage",
//                                        qos: .userInteractive,
//                                        attributes: .concurrent)
//    
//    var categoriesStorage: [TrackerCategory] {
//        get {
//            storage.sync { categories }
//        }
//        set {
//            storage.sync(flags: .barrier) { categories = newValue }
//        }
//    }
//}
//

protocol DataProviderProtocol: AnyObject {
    func getCategories() -> [TrackerCategory]
    func addCategory(category: TrackerCategory)
    func addTrackerToCategory(tracker: Tracker, category: TrackerCategory)
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
        categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore(),
        recordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
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
    
    func addTrackerToCategory(tracker: Tracker, category: TrackerCategory) {
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
