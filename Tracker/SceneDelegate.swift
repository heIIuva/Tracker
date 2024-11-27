//
//  SceneDelegate.swift
//  Tracker
//
//  Created by big stepper on 02/10/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = selectRootVC()
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func selectRootVC() -> UIViewController {
        var vc: UIViewController
        
        if Flags.shared.isFirstLaunch() {
            vc = OnboardingPageViewController(transitionStyle: .pageCurl,
                                              navigationOrientation: .horizontal)
        } else {
            vc = TabBarController()
        }
        
        return vc
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}


}

