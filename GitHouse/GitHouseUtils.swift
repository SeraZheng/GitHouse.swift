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

//MARK: Fix bug of DGElasticPullToRefresh
extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}

public class GitHouseUtils: NSObject {
    
    public var keychain: Keychain = Keychain.init(service: "io.github.serazheng.GitHouse")
    public var config: TokenConfiguration { return TokenConfiguration(_accessToken) }
    static public var myProfile: User?
    public var authenticated = false
    private var _accessToken: String?
    
    private override init() {}

    static public var themeColor: UIColor {
        return UIColor(red: 0/255.0, green: 100.0/255.0, blue: 174.0/255.0, alpha: 1.0)
    }
    
    public static var sharedInstance: GitHouseUtils {
        struct Static {
            static let instance = GitHouseUtils()
        }
        return Static.instance
    }
    
    public var accessToken: String? {
        
        get {
            do {
                try _accessToken = keychain.get("access_token")
            } catch {
                _accessToken = nil
            }
            return _accessToken!
        }
        set {
            _accessToken = newValue
        
            do {
                try keychain.set(_accessToken!, key: "access_token")
        
            } catch {
                fatalError()
            }
        }
    }
}