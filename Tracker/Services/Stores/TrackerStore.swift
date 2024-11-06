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
}


final class TrackerStore: NSObject {
    
    //MARK: - Init/Singletone
    
    private init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private convenience override init() {
        guard let context = (UIApplication.shared.delegate as?
                             AppDelegate)?.persistentContainer.viewContext
        else { fatalError("Could not initialize TrackerStore") }
        
        self.init(context: context)
    }
    
    static let shared = TrackerStore()
    
    //MARK: - Properties
    
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
        return try? context.fetch(request).first
    }
}
