//
//  StatiscticsStore.swift
//  Tracker
//
//  Created by big stepper on 26/11/2024.
//

import Foundation

final class StatiscticsStore {
    
    //MARK: - Singletone
    
    static let shared = StatiscticsStore()
    private init(){}
    
    //MARK: - Properties
    
    private enum Keys: String {
        case streak
        case perfectDays
        case completedTrackers
        case averageValue
    }

    
    private let storage = UserDefaults.standard
    
    private var streak: Int {
        get {
            storage.integer(forKey: Keys.streak.rawValue)
        } set {
            storage.set(newValue, forKey: Keys.streak.rawValue)
        }
    }
    
    private var perfectDays: Int {
        get {
            storage.integer(forKey: Keys.perfectDays.rawValue)
        } set {
            storage.set(newValue, forKey: Keys.perfectDays.rawValue)
        }
    }
    
    private var completedTrackers: Int {
        get {
            storage.integer(forKey: Keys.completedTrackers.rawValue)
        } set {
            storage.set(newValue, forKey: Keys.completedTrackers.rawValue)
        }
    }
    
    private var averageValue: Double {
        get {
            storage.double(forKey: Keys.averageValue.rawValue)
        } set {
            storage.set(newValue, forKey: Keys.averageValue.rawValue)
        }
    }
    
    //MARK: - Methods
    
    
}
