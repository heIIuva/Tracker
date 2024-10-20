//
//  Calendar+Extensions.swift
//  Tracker
//
//  Created by big stepper on 20/10/2024.
//

import Foundation


extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date = Date()) -> Int? {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day
    }
}

