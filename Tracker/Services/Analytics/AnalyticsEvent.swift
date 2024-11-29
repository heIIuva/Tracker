//
//  AnalyticsEvent.swift
//  Tracker
//
//  Created by big stepper on 29/11/2024.
//

import Foundation

struct AnalyticsEvent {
    
    enum EventType: String {
        case open = "open"
        case close = "close"
        case click = "click"
    }
    
    enum ScreenType: String {
        case main = "Main"
    }
    
    enum ItemType: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }
    
    let event: EventType
    let screen: ScreenType
    let item: ItemType?
    
    init(
        event: EventType,
        screen: ScreenType,
        item: ItemType? = nil
    ) {
        self.event = event
        self.screen = screen
        self.item = item
    }
}
