//
//  Flags.swift
//  Tracker
//
//  Created by big stepper on 24/11/2024.
//

import Foundation


final class Flags {
    
    //MARK: - Singletone
    
    static let shared = Flags()
    private init(){}
    
    //MARK: - Methods
    
    func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }    
}
