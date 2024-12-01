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
        case statistics = "Statistics"
        case createNewTrack = "CreateNewTrack"
        case newHabitOrEvent = "NewHabitOrEvent"
        case categoryVC = "CategoryVC"
        case timetableVC = "TimetableVC"
    }
    
    enum ItemType: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
        case searchBar = "search_bar"
        case datePicker = "date_picker"
        case complete = "complete"
        case selectedFilter = "selected_filter"
        case openedStatistics = "opened_statistics"
        case newHabit = "new_habit"
        case newEvent = "new_event"
        case cancel = "cancel"
        case create = "create"
        case addedCategory = "added_category"
        case selectedCategory = "selected_category"
        case setupTimetable = "setup_timetable"
        case pin = "pin"
        case deleteTrack = "delete_track"
        case editTrack = "edit_track"
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
