//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by big stepper on 04/11/2024.
//

import UIKit
import CoreData


protocol TrackerCategoryStoreProtocol: AnyObject {
    var delegate: TrackerCategoryStoreDelegate? { get set }
    var categories: [TrackerCategory] { get }
    func addCategoryToCoreData(_ category: TrackerCategory)
    func addTrackerToCategory(_ tracker: Tracker, _ category: String)
}


protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategory()
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
    
    var categories: [TrackerCategory] {
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
    
    private func fetchCategoryCoreData(from category: String) -> TrackerCategoryCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "title == %@", category)
        return try? context.fetch(request).first
    }
}

//MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addCategoryToCoreData(_ category: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        categoryCoreData.trackersInCategory = NSSet(array: category.trackers)
        appDelegate.saveContext()
    }
    
    func addTrackerToCategory(_ tracker: Tracker, _ category: String) {
        let trackerCoreData = trackerStore.fetchTrackerCoreData(from: tracker)
        guard
            let category = fetchCategoryCoreData(from: category),
            let trackers = category.trackersInCategory as? Set<TrackerCoreData>
        else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = category
            newCategory.trackersInCategory = NSSet(array: [trackerCoreData])
            appDelegate.saveContext()
            return
        }
        category.trackersInCategory = trackers.union([trackerCoreData]) as NSSet
        appDelegate.saveContext()
        
        print("called addTrackerToCategory method in TrackerCategoryStore")
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategory()
    }
}

