//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by big stepper on 04/11/2024.
//

import UIKit
import CoreData


protocol TrackerRecordStoreProtocol: AnyObject {
    var delegate: TrackerRecordStoreDelegate? { get set }
    var records: Set<TrackerRecord> { get }
    func addRecord(_ record: TrackerRecord)
    func deleteRecord(_ record: TrackerRecord)
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecord()
}


final class TrackerRecordStore: NSObject {
    
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
    
    var records: Set<TrackerRecord> {
        guard let recordsCoreData = fetchedResultsController.fetchedObjects
        else { return [] }
        let records = recordsCoreData.compactMap { fetchRecord(from: $0) }
        return Set(records)
    }
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let trackerStore = TrackerStore.shared
    private let context: NSManagedObjectContext
    private let appDelegate: AppDelegate
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.id,
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
    
    private func fetchRecord(from coreData: TrackerRecordCoreData) -> TrackerRecord? {
        guard
            let id = coreData.id,
            let date = coreData.date
        else { return nil }
        
        return TrackerRecord(id: id, date: date)
    }
}

//MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func addRecord(_ record: TrackerRecord) {
        let coreData = TrackerRecordCoreData(context: context)
        coreData.id = record.id
        coreData.date = record.date
        
        let tracker = trackerStore.fetchTrackerFromCoreDataById(record.id)
        coreData.tracker = tracker
        appDelegate.saveContext()
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ && date == %@",
                                        record.id as CVarArg,
                                        record.date as CVarArg)
        
        guard let coreData = try? context.fetch(request).first
        else { return }
        
        context.delete(coreData)
        appDelegate.saveContext()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecord()
    }
}
