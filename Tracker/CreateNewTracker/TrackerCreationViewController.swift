//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by big stepper on 09/10/2024.
//

import UIKit


protocol NewTrackerVCDelegate: AnyObject {
    func reloadCollectionView()
}


final class TrackerCreationViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .label
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle(
            NSLocalizedString("habit", comment: ""),
            for: .normal
        )
        button.setTitleColor(.systemBackground, for: .normal)
        button.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .label
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle(
            NSLocalizedString("event", comment: ""),
            for: .normal
        )
        button.setTitleColor(.systemBackground, for: .normal)
        button.addTarget(self, action: #selector(didTapEventButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Properties
    
    weak var delegate: TrackerCreationDelegate?
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - UI methods
    
    private func setupUI() {
        self.title = NSLocalizedString("creation", comment: "")
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        
        NSLayoutConstraint.activate([
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            eventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 357),
            eventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    //MARK: - Obj-C methods
    
    @objc private func didTapHabitButton() {
        AnalyticsService.trackEvent(AnalyticsEvent(
            event: .click,
            screen: .createNewTrack,
            item: .newHabit)
        )
        
        let newHabitOrEventVC = NewHabitOrEventViewController(
            nibName: nil,
            bundle: nil,
            delegate: self,
            isHabit: true,
            dataProvider: DataProvider(
                categoryStore: TrackerCategoryStore(),
                recordStore: TrackerRecordStore()
            ),
            mode: .create,
            tracker: nil,
            category: nil
        )
        self.present(UINavigationController(rootViewController: newHabitOrEventVC), animated: true, completion: nil)
    }
    
    @objc private func didTapEventButton() {
        AnalyticsService.trackEvent(AnalyticsEvent(
            event: .click,
            screen: .createNewTrack,
            item: .newHabit)
        )
        
        let newHabitOrEventVC = NewHabitOrEventViewController(
            nibName: nil,
            bundle: nil,
            delegate: self,
            isHabit: false,
            dataProvider: DataProvider(
                categoryStore: TrackerCategoryStore(),
                recordStore: TrackerRecordStore()
            ),
            mode: .create,
            tracker: nil,
            category: nil
        )
        self.present(UINavigationController(rootViewController: newHabitOrEventVC), animated: true, completion: nil)
    }
}

extension TrackerCreationViewController: NewTrackerVCDelegate {
    
    func reloadCollectionView() {
        delegate?.reloadCollectionView()
    }
}
