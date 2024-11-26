//
//  FilterViewModel.swift
//  Tracker
//
//  Created by big stepper on 26/11/2024.
//

import Foundation


protocol FilterViewModelProtocol {
    var onFiltersUpdate: (() -> Void)? { get set }
    func isSelected(filter: Filter) -> Bool
    func setSelected(filter: Filter)
}


final class FilterViewModel: FilterViewModelProtocol {
    
    //MARK: - Init
    
    init(selectedFilter: Filter?) {
        self.selectedFilter = selectedFilter
    }
    
    //MARK: - Properties
    
    weak var delegate: FilterDelegate?
        
    var onFiltersUpdate: (() -> Void)?
    
    private var selectedFilter: Filter?
    
    //MARK: - Methods
    
    func isSelected(filter: Filter) -> Bool {
        if filter == selectedFilter {
            return true
        } else {
            return false
        }
    }
    
    func setSelected(filter: Filter) {
        self.selectedFilter = filter
        onFiltersUpdate?()
        switch filter {
        case .all:
            delegate?.allTrackersFilter()
        case .today:
            delegate?.trackersForTodayFilter()
        case .incomplete:
            delegate?.incompletedTrackersFilter()
        case .complete:
            delegate?.completedTrackersFilter()
        }
        delegate?.updateFilter(filter: filter)
    }
}
