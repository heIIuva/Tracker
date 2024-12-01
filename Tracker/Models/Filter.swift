//
//  Filter.swift
//  Tracker
//
//  Created by big stepper on 26/11/2024.
//


import Foundation


enum Filter: String, CaseIterable {
    case all
    case today
    case complete
    case incomplete
    
    var localized: String {
        switch self {
        case .all: return NSLocalizedString("alltrackers", comment: "")
        case .today: return NSLocalizedString("todaytrackers", comment: "")
        case .complete: return NSLocalizedString("completetrackers", comment: "")
        case .incomplete: return NSLocalizedString("incompletetrackers", comment: "")
        }
    }
}
