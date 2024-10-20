//
//  Int+Extensions.swift
//  Tracker
//
//  Created by big stepper on 20/10/2024.
//

import Foundation


extension Int {
    
    private enum Days: String {
        case one = "день"
        case twoToFour = "дня"
        case greaterThanFour = "дней"
    }
    
    func string() -> String {
        switch self {
        case self where self % 10 == 1:
            return "\(self) \(Days.one.rawValue)"
        case self where self % 10 > 1 && self % 10 < 5:
            return "\(self) \(Days.twoToFour.rawValue)"
        case self where self % 10 > 4 || self == 0:
            return "\(self) \(Days.greaterThanFour.rawValue)"
        default:
            return "\(self) \(Days.greaterThanFour.rawValue)"
        }
    }
}
