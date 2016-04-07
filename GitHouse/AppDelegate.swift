//
//  AppDelegate.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/24.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit
import Localize_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        GitHouseStyle.themeConfig()
        
        window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        
        if GitHouseUtils.isValidated {
            self.setHomeTabViewController(window!)
        } else {
            weak var weakSelf = self
            window?.rootViewController = UserLoginViewController.init(authCompletion: { (user) in
                let strongSelf = weakSelf!
                strongSelf.setHomeTabViewController(self.window!)
            })
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }

        //MARK: setRootViewController
    
    func setHomeTabViewController(window: UIWindow) -> Void {
        
//        let newsVC = NewsViewController(nibName: nil, bundle: nil)
        let respositiesVC = BaseNavigationController.init(rootViewController:RepositoriesViewController(nibName: nil, bundle: nil))
        let discoverVC = UINavigationController.init(rootViewController:ContactViewController(nibName: nil, bundle: nil))
        let profileVC = UINavigationController.init(rootViewController:ProfileViewController())
        
        let rootVC = UITabBarController.init(nibName: nil, bundle: nil)
        rootVC.viewControllers = [respositiesVC, discoverVC, profileVC]

        window.rootViewController = rootVC
    }

}

