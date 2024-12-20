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
    func deleteCategoryFromCoreData(_ category: String)
    func editCategory(_ category: String, to newCategory: String)
    func updateTrackerCategory(_ tracker: UUID, _ category: String)
    func pinTracker(_ tracker: UUID, _ category: String)
    func unpinTracker(_ tracker: UUID)
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
        else {
            assertionFailure("AppDelegate not found")
            self.init()
            return
        }
        
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
        request.predicate = NSPredicate(format: "title == %@", category as CVarArg)
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching TrackerCategoryCoreData: \(error)")
            return nil
        }
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
        trackerCoreData.lastCategory = category
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
    }
    
    func deleteCategoryFromCoreData(_ category: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@",
                                        category as CVarArg)

        guard let coreData = try? context.fetch(request).first
        else {
            return
        }
        
        context.delete(coreData)
        appDelegate.saveContext()
    }
    
    func updateTrackerCategory(_ tracker: UUID, _ category: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@",
                                        category as CVarArg)
        
        guard
            let trackerCoreData = trackerStore.fetchTrackerFromCoreDataById(tracker),
            let category = try? context.fetch(request).first
        else {
            return
        }
        
        trackerCoreData.category = category
        
        appDelegate.saveContext()
    }
    
    func editCategory(_ category: String, to newCategory: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@",
                                        category as CVarArg)

        guard let coreData = try? context.fetch(request).first
        else {
            return
        }
        
        coreData.title = newCategory
        
        appDelegate.saveContext()
    }
    
    func pinTracker(_ tracker: UUID, _ category: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@",
                                        category as CVarArg)
        if let trackerCoreData = trackerStore.fetchTrackerFromCoreDataById(tracker) {
            guard
                let category = try? context.fetch(request).first
            else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = category
                newCategory.trackersInCategory = NSSet(array: [trackerCoreData])
                appDelegate.saveContext()
                return
            }
            
            trackerCoreData.lastCategory = trackerCoreData.category?.title
            trackerCoreData.category = category
                        
            appDelegate.saveContext()
        }
    }
    
    func unpinTracker(_ tracker: UUID) {
        guard
            let trackerCoreData = trackerStore.fetchTrackerFromCoreDataById(tracker)
        else {
            return
        }
        
        guard let category = trackerCoreData.lastCategory else { return }
                
        updateTrackerCategory(tracker, category)
        
        appDelegate.saveContext()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategory()
    }
}

