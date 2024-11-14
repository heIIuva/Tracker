//
//  AlertModel.swift
//  Tracker
//
//  Created by big stepper on 14/11/2024.
//

import Foundation


struct AlertModel {
    let title: String
    let message: String
    let button: String
    let completion: (() -> Void)
    var secondButton: String?
    var secondCompletion: (() -> Void)?
}
