//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit


final class StatisticsViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
