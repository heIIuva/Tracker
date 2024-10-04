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
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                           image: UIImage(named: "statisticsBarInactive"),
                                                           selectedImage: UIImage(named: "statisticsBarActive"))
        
        let trackerNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackerNavigationController.navigationBar.prefersLargeTitles = true
        let statisticNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticNavigationController.navigationBar.prefersLargeTitles = true
        
        setViewControllers([trackerNavigationController, statisticNavigationController], animated: true)
    }
}
