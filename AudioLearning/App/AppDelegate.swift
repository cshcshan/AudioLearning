//
//  AppDelegate.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RealmSwift
import Lottie

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print(NSHomeDirectory())
        setupRealm()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let startCoordinator: (() -> Void) = { [weak self] in
            guard let `self` = self else { return }
            self.appCoordinator = AppCoordinator(window: self.window!)
            _ = self.appCoordinator.start()
        }
        setupLaunchScreen(startCoordinator)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - Realm

extension AppDelegate {
    
    private func setupRealm() {
        var configuration = Realm.Configuration.defaultConfiguration
        // TODO: updating Realm version
        configuration.schemaVersion = 0
        Realm.Configuration.defaultConfiguration = configuration
    }
}

// MARK: - LaunchScreen

extension AppDelegate {
    
    private func setupLaunchScreen(_ startCoordinator: @escaping (() -> Void)) {
        guard let window = self.window else { return startCoordinator() }
        guard let launchScreenVC = UIStoryboard(name: "LaunchScreen", bundle: .main).instantiateInitialViewController() else { return startCoordinator() }
        guard let launchScreenView = launchScreenVC.view else { return startCoordinator() }
        let animationView = AnimationView(filePath: Bundle.main.path(forResource: "around-the-world",
                                                                     ofType: "json")!)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        launchScreenView.addSubview(animationView)
        launchScreenView.backgroundColor = Appearance.backgroundColor
        let views = ["subview": animationView]
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|",
                                                        options: [], metrics: nil, views: views)
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|",
                                                      options: [], metrics: nil, views: views)
        launchScreenView.addConstraints(horizontal + vertical)
        UIView.animate(withDuration: 3, animations: {
            launchScreenView.alpha = 0
        })
        animationView.play()
        
        window.rootViewController = launchScreenVC
        window.makeKeyAndVisible()
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
            startCoordinator()
        })
    }
}
