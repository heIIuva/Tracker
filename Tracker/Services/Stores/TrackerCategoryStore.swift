//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by big stepper on 04/11/2024.
//

import UIKit
import CoreData


struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}


protocol TrackerCategoryStoreProtocol: AnyObject {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func addCategoryToCoreData(_ category: TrackerCategory)
    func addTrackerToCategory(_ tracker: Tracker, _ category: TrackerCategory)
    func provideCategories() -> [TrackerCategory]
}


protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}


final class TrackerCategoryStore: NSObject {
    
    //MARK: - Init
    
    init(
        context: NSManagedObjectContext,
        appDelegate: AppDelegate
    ) {
        self.context = context
        self.appDelegate = appDelegate
    }
    
    convenience override init() {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        else { fatalError("Could not initialize TrackerCategoryStore") }
        
        self.init(
            context: appDelegate.persistentContainer.viewContext,
            appDelegate: appDelegate
        )
    }
    
    //MARK: - Properties
    
    private var categories: [TrackerCategory] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects
        else { return [] }
        let categories = categoriesCoreData.compactMap({ fetchCategory(from: $0) })
        return categories
    }
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private let trackerStore = TrackerStore.shared
    private let context: NSManagedObjectContext
    private let appDelegate: AppDelegate
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title,
                                                         ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching TrackerCategoryCoreData: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    //MARK: - Methods
    
    private func fetchCategory(from categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard
            let title = categoryCoreData.title,
            let trackers = categoryCoreData.trackersInCategory as? Set<TrackerCoreData>
        else { return nil }
        
        return TrackerCategory(
            title: title,
            trackers: trackers.compactMap { trackerStore.fetchTracker(from: $0) }
        )
    }
    
    private func fetchCategoryCoreData(from category: TrackerCategory) -> TrackerCategoryCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "title == %@", category.title)
        return try? context.fetch(request).first
    }
}

//MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func addCategoryToCoreData(_ category: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        categoryCoreData.trackersInCategory = NSSet(array: category.trackers)
        appDelegate.saveContext()
    }
    
    func addTrackerToCategory(_ tracker: Tracker, _ category: TrackerCategory) {
        let trackerCoreData = trackerStore.fetchTrackerCoreData(from: tracker)
        guard
            let category = fetchCategoryCoreData(from: category),
            let trackers = category.trackersInCategory as? Set<TrackerCoreData>
        else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = category.title
            newCategory.trackersInCategory = NSSet(array: [trackerCoreData])
            return appDelegate.saveContext()
        }
        category.trackersInCategory = trackers.union([trackerCoreData]) as NSSet
        appDelegate.saveContext()
    }
    
    func provideCategories() -> [TrackerCategory] {
        categories
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
}

