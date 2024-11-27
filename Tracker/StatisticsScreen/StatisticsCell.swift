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
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    
    private lazy var bodyView: UIView = {
        let view = CustomGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var counter: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    //MARK: - Methods
    
    private func layoutCell() {
        addSubview(bodyView)
        bodyView.addSubviews(counter, title)
                
        NSLayoutConstraint.activate([
            bodyView.heightAnchor.constraint(equalToConstant: 90),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            
            counter.heightAnchor.constraint(equalToConstant: 41),
            counter.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 12),
            counter.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -12),
            counter.topAnchor.constraint(equalTo: bodyView.topAnchor, constant: 12),
            
            title.heightAnchor.constraint(equalToConstant: 18),
            title.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -12),
            title.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: -12)
        ])
    }
    
    func configureCell(counter: Int, title: String) {
        self.counter.text = "\(counter)"
        self.title.text = title
        print("called")
    }
}
