//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit


final class StatisticsViewController: UIViewController {
    
    //MARK: - Properties
    
    
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarItem = UITabBarItem(title: "Статистика",
                                       image: UIImage(named: ""),
                                       selectedImage: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
}
