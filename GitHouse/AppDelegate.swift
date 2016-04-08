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
        
        if !GitHouseUtils.isValidated {
            setHomeTabViewController(window!)
        } else {
            
            window?.rootViewController = UserLoginViewController(authCompletion: { [weak self](user) in
                guard let strongSelf = self else { return }
                strongSelf.setHomeTabViewController(strongSelf.window!)
            })
        }
        
        window?.makeKeyAndVisible()
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if url.scheme == GitHouseUtils.urlScheme {
            
            KRProgressHUD.show(progressHUDStyle: KRProgressHUDStyle.BlackColor, maskType: KRProgressHUDMaskType.Clear, activityIndicatorStyle: KRProgressHUDActivityIndicatorStyle.White, font: nil, message: "Authenticating....".localized(), image: nil)
            
            GitHouseUtils.oAuthConfig.handleOpenURL(url) { [weak self]config in
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    guard let strongSelf = self else { return }
                    
                    GitHouseUtils.authenticated = true
                    GitHouseUtils.accessToken = config.accessToken
                    
                    if GitHouseUtils.isHomeLoaded {
                        
                        GitHouseUtils.topViewController?.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        
                        strongSelf.setHomeTabViewController(strongSelf.window!)
                    }
                })
            }
        }
        
        return false
    }
    
    //MARK: setRootViewController
    
    func setHomeTabViewController(window: UIWindow) -> Void {
        
//        let newsVC = NewsViewController(nibName: nil, bundle: nil)
        let respositiesVC = BaseNavigationController.init(rootViewController:RepositoriesViewController(nibName: nil, bundle: nil))
        let discoverVC = UINavigationController.init(rootViewController:ContactViewController(nibName: nil, bundle: nil))
        let profileVC = UINavigationController.init(rootViewController:ProfileViewController())
        
        let rootVC = UITabBarController.init(nibName: nil, bundle: nil)
        rootVC.viewControllers = [respositiesVC, discoverVC, profileVC]
        window.addSubview(rootVC.view)

        let loginVC = window.rootViewController
        loginVC?.view.removeFromSuperview()
        
        window.rootViewController = rootVC
    }

}

