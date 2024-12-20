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
            let configuration = YMMYandexMetricaConfiguration(apiKey: "5cf6fa58-e933-4a83-bc49-aeec7f2ca773")
        else {
            return false
        }
        
        YMMYandexMetrica.activate(with: configuration)
        return true
    }
    
    static func trackEvent(_ analyticsEvent: AnalyticsEvent) {
        var params: [String: Any] = ["screen": analyticsEvent.screen.rawValue]
        if let item = analyticsEvent.item {
            params["item"] = item.rawValue
        }
        
        YMMYandexMetrica.reportEvent(analyticsEvent.event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}


