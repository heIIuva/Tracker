//
//  Weekday.swift
//  Tracker
//
//  Created by big stepper on 15/10/2024.
//

import Foundation

enum Weekday: String, CaseIterable, Codable {
    case monday /*= "monday"*/
    case tuesday /*= "tuesday"*/
    case wednesday /*= "wednesday"*/
    case thursday /*= "thursday"*/
    case friday /*= "friday"*/
    case saturday /*= "saturday"*/
    case sunday /*= "sunday"*/
    
    var weekday: String {
        switch self {
        case .monday: return NSLocalizedString("monday", comment: "")
        case .tuesday: return NSLocalizedString("tuesday", comment: "")
        case .wednesday: return NSLocalizedString("wednesday", comment: "")
        case .thursday: return NSLocalizedString("thursday", comment: "")
        case .friday: return NSLocalizedString("friday", comment: "")
        case .saturday: return NSLocalizedString("saturday", comment: "")
        case .sunday: return NSLocalizedString("sunday", comment: "")
        }
    }
    
    var shortened: String {
        switch self {
        case .monday: return NSLocalizedString("mon", comment: "")
        case .tuesday: return NSLocalizedString("tue", comment: "")
        case .wednesday: return NSLocalizedString("wed", comment: "")
        case .thursday: return NSLocalizedString("thu", comment: "")
        case .friday: return NSLocalizedString("fri", comment: "")
        case .saturday: return NSLocalizedString("sat", comment: "")
        case .sunday: return NSLocalizedString("sun", comment: "")
        }
    }
    
    var int: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
}
