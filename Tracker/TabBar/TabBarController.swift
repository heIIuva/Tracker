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
        trackersViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("tracker",
                                                                                  comment: ""),
                                                        image: UIImage(named: "trackersBarInactive"),
                                                        selectedImage: UIImage(named: "trackersBarActive"))
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.navigationBar.prefersLargeTitles = true
        trackersViewController.view.backgroundColor = .systemBackground
        trackersNavigationController.navigationBar.backgroundColor = .systemBackground
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("stats",
                                                                                    comment: ""),
                                                           image: UIImage(named: "statisticsBarInactive"),
                                                           selectedImage: UIImage(named: "statisticsBarActive"))
        
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.navigationBar.prefersLargeTitles = true
        statisticsViewController.view.backgroundColor = .systemBackground
        statisticsNavigationController.navigationBar.backgroundColor = .systemBackground
        
        setViewControllers([trackersNavigationController, statisticsNavigationController], animated: true)
    }
}
