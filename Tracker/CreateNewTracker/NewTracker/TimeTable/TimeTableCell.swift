//
//  TimeTableCell.swift
//  Tracker
//
//  Created by big stepper on 15/10/2024.
//

import UIKit


final class TimeTableCell: UITableViewCell {
    
    //MARK: - Reuse identifier
    
    static let reuseIdentifier: String = "TimeTableCell"
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI properties
    
    private lazy var cellBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray
        view.alpha = 0.3
        return view
    }()
    
    private lazy var daylabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    //MARK: - Methods
    
    private func layoutCell() {
        addSubviews(cellBackgroundView, daylabel)
        
        NSLayoutConstraint.activate([
            cellBackgroundView.heightAnchor.constraint(equalToConstant: 75),
            cellBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            
            daylabel.leadingAnchor.constraint(equalTo: cellBackgroundView.leadingAnchor, constant: 16),
            daylabel.centerYAnchor.constraint(equalTo: cellBackgroundView.centerYAnchor),
            daylabel.heightAnchor.constraint(equalToConstant: 31),
        ])
    }
    
    func setupCell(text: String, accessoryView: UISwitch) {
        daylabel.text = text
        self.accessoryView = accessoryView
    }
}
