//
//  TabBarController.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit


final class TabBarController: UITabBarController {
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                        image: UIImage(named: "trackersBarInactive"),
                                                        selectedImage: UIImage(named: "trackersBarActive"))
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.navigationBar.prefersLargeTitles = true
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                           image: UIImage(named: "statisticsBarInactive"),
                                                           selectedImage: UIImage(named: "statisticsBarActive"))
        
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.navigationBar.prefersLargeTitles = true
        
        setViewControllers([trackersNavigationController, statisticsNavigationController], animated: true)
    }
}
