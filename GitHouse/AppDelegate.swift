//
//  AppDelegate.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/24.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit
import RAMAnimatedTabBarController
import Localize_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let config = OAuthConfiguration(token: "e8811b70b5098df6b6d3", secret: "029d4f638fd4e52b9b3723bee1c333f75dee40cc", scopes: ["repo", "read:org"])
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().barTintColor =  UIColor(red: 0/255.0, green: 100.0/255.0, blue: 174.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.flatWhiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false
        )
        
        window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        
        if GitHouseUtils.sharedInstance.accessToken != nil {
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        config.handleOpenURL(url) { config in
            self.loadCurrentUser(config) // purely optional of course
        }
        return false
    }
    
    func loadCurrentUser(config: TokenConfiguration) {
        Octokit(config).me() { response in
            switch response {
            case .Success(let user):
                print(user.login)
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: setRootViewController
    
    func setHomeTabViewController(window: UIWindow) -> Void {
        
//        let newsVC = NewsViewController(nibName: nil, bundle: nil)
        let respositiesVC = BaseNavigationController.init(rootViewController:RepositoriesViewController(nibName: nil, bundle: nil))
        let discoverVC = UINavigationController.init(rootViewController:DiscoverViewController(nibName: nil, bundle: nil))
        let profileVC = UINavigationController.init(rootViewController:ProfileViewController())
        
        let rootVC = UITabBarController.init(nibName: nil, bundle: nil)
        rootVC.viewControllers = [respositiesVC, discoverVC, profileVC]

        window.rootViewController = rootVC
    }

}

