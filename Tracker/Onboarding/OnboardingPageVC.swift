//
//  OnboardingPageVC.swift
//  Tracker
//
//  Created by big stepper on 14/11/2024.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    //MARK: - Properties
    
    private lazy var pages: [UIViewController] = {
        let blueOnboarding = OnboardingViewController(nibName: nil,
                                                      bundle: nil,
                                                      title: NSLocalizedString("bluescreen",
                                                                               comment: ""),
                                                      backgroundImage: UIImage(named: "OnboardingBlue"))
        
        let redOnboarding = OnboardingViewController(nibName: nil,
                                                     bundle: nil,
                                                     title: NSLocalizedString("redscreen",
                                                                              comment: ""),
                                                     backgroundImage: UIImage(named: "OnboardingRed"))
        
        return [blueOnboarding, redOnboarding]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .ypDarkGray
        return pageControl
    }()
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

//MARK: - Extensions

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
            
        let previousIndex = viewControllerIndex - 1
                
        if previousIndex > 0 && previousIndex < pages.count {
            return pages[previousIndex]
        } else if previousIndex == 0 {
            return pages.first
        } else {
            return pages.last
        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
            
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex > 0 && nextIndex < pages.count {
            return pages[nextIndex]
        } else if nextIndex == 0 {
            return pages.last
        } else {
            return pages.first
        }
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
