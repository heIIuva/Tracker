//
//  AnalyticsService.swift
//  Tracker
//
//  Created by big stepper on 24/11/2024.
//

import Foundation
import YandexMobileMetrica


struct AnalyticsService {
    static func initMetrica() -> Bool {
        guard
            let configuration = YMMYandexMetricaConfiguration(apiKey: "7eb19d13-5c3a-4923-b9e4-60d5b629771c")
        else {
            return true
        }
        
        YMMYandexMetrica.activate(with: configuration)
        return true
    }
    
    static func trackEvent(_ event: String, _ params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
