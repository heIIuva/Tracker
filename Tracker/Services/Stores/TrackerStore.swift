//
//  TrackerStore.swift
//  Tracker
//
//  Created by big stepper on 04/11/2024.
//


import UIKit
import CoreData


protocol TrackerStoreProtocol: AnyObject {
    func fetchTracker(from coreData: TrackerCoreData) -> Tracker?
    func fetchTrackerCoreData(from tracker: Tracker) -> TrackerCoreData
    func fetchTrackerFromCoreDataById(_ id: UUID) -> TrackerCoreData?
    func deleteTrackerFromCoreData(_ tracker: Tracker)
    func editTracker(tracker: UUID, to newTracker: Tracker)
}


final class TrackerStore: NSObject {
    
    //MARK: - Init/Singletone
    
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
    
    static let shared = TrackerStore()
    
    //MARK: - Properties
        
    private let appDelegate: AppDelegate
    private let uiColorMarshalling = UIColorMarshalling.shared
    private let context: NSManagedObjectContext
}

//MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    func fetchTracker(from coreData: TrackerCoreData) -> Tracker? {
        guard
            let id = coreData.id,
            let name = coreData.name,
            let colorHex = coreData.color,
            let emoji = coreData.emoji,
            let timeTable = coreData.timeTable as? [Weekday]
        else { return nil }
        
        return Tracker(
            id: id,
            name: name,
            color: uiColorMarshalling.color(from: colorHex),
            emoji: emoji,
            timeTable: timeTable
        )
    }
    
    func fetchTrackerCoreData(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.timeTable = tracker.timeTable as NSObject
        print(trackerCoreData)
        return trackerCoreData
    }
    
    func fetchTrackerFromCoreDataById(_ id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching tracker by id: \(error)")
            return nil
        }
    }
    
    func deleteTrackerFromCoreData(_ tracker: Tracker) {
        guard let trackerToDelete = fetchTrackerFromCoreDataById(tracker.id) else { return }
        context.delete(trackerToDelete)
        appDelegate.saveContext()
    }
    
    func editTracker(tracker: UUID, to newTracker: Tracker) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@",
                                        tracker as CVarArg)

        guard let coreData = try? context.fetch(request).first
        else {
            return
        }
        
        coreData.name = newTracker.name
        coreData.emoji = newTracker.emoji
        coreData.color = uiColorMarshalling.hexString(from: newTracker.color)
        coreData.timeTable = newTracker.timeTable as NSObject
                
        appDelegate.saveContext()
    }
}
