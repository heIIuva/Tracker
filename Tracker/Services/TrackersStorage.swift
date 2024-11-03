//
//  TrackerSrorage.swift
//  Tracker
//
//  Created by big stepper on 16/10/2024.
//

import Foundation


final class TrackersStorage {
    
    //MARK: - Singletone
    
    static let shared = TrackersStorage()
    
    private init(){}
    
    //MARK: - Properties
    
    private var categories: [TrackerCategory] = [TrackerCategory(title: "Mock",
                                                                 trackers:
                                                                  [Tracker(id: UUID(),
                                                                           name: "firstTracker",
                                                                           color: .ypBlue,
                                                                           emoji: "😄",
                                                                           timeTable: [.monday]),
                                                                   Tracker(id: UUID(),
                                                                           name: "secondTracker",
                                                                           color: .ypRed,
                                                                           emoji: "😊",
                                                                           timeTable: [.friday])
                                                                 ]),
      
  ]
    
    //MARK: - Storage
    
    private let storage = DispatchQueue(label: "trackerStorage",
                                        qos: .userInteractive,
                                        attributes: .concurrent)
    
    var categoriesStorage: [TrackerCategory] {
        get {
            storage.sync { categories }
        }
        set {
            storage.sync(flags: .barrier) { categories = newValue }
        }
    }
}
