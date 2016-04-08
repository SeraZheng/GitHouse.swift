//
//  GitHouseUtils.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/28.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import Foundation
import KeychainAccess
import Octokit

public struct GitHouseUtils {
    
    public static let urlScheme = "githouse"
    private static let tokenKey = "access_token"
    
    public static var keychain = Keychain(service: "io.github.serazheng.GitHouse")
    public static let oAuthConfig = OAuthConfiguration(token: "e8811b70b5098df6b6d3", secret: "029d4f638fd4e52b9b3723bee1c333f75dee40cc", scopes: ["repo", "read:org"])
    
    public static var octokit: Octokit?
    
    public static var accessToken: String? {
        didSet {
            octokit = Octokit(TokenConfiguration(accessToken))
            
            do {
                try keychain.set(accessToken!, key: tokenKey)
                
            } catch {
                fatalError()
            }
        }
    }
    
    public static var isValidated: Bool {
        
        var accessToken: String?
        do {
            try accessToken = keychain.get(tokenKey)
        } catch {
            accessToken = nil
        }
        
        if accessToken != nil {
            self.accessToken = accessToken
            return true
        } else {
            return false
        }
    }
    
    public static var myProfile: User?
    
    public static var authenticated = false
    
    public static var isHomeLoaded = false 
}

//MARK:Navigator

extension GitHouseUtils {
    
    public static var rootViewController: UIViewController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController
    }
    
    public static var topViewController: UIViewController? {
        
        guard rootViewController is UITabBarController else { return nil }
        return (rootViewController as! UITabBarController).selectedViewController?.navigationController?.topViewController
    }
    
    public static var visibleViewController: UIViewController? {
        return getVisible(rootViewController!)
    }
    
    public static func getVisible(fromViewController: UIViewController) -> UIViewController {
        if fromViewController.isKindOfClass(UINavigationController) {
            
            return getVisible((fromViewController as! UINavigationController).visibleViewController!)
        } else if fromViewController.isKindOfClass(UITabBarController) {
            
            return getVisible((fromViewController as! UITabBarController).selectedViewController!)
        } else {
            
            if let presentedVC = fromViewController.presentedViewController {
                return getVisible(presentedVC)
            } else {
                return fromViewController
            }
        }
    }
}
