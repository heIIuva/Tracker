//
//  StatisticCell.swift
//  Tracker
//
//  Created by big stepper on 26/11/2024.
//

import UIKit


final class StatisticsCell: UITableViewCell {
    
    //MARK: - Reuse identifier
    
    static let reuseIdentifier: String = "StatisticsCell"
    
    //MARK: - Init
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    
    private lazy var bodyView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    //MARK: - Methods
    
    
}
