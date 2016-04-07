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
    
    private static let tokenKey = "access_token"
    
    public static var keychain = Keychain(service: "io.github.serazheng.GitHouse")
    
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
        if let accessToken = try? keychain.get(tokenKey) {
            self.accessToken = accessToken
            
            return true
        }
        return false
    }
    
    public static var myProfile: User?
    
    public static var authenticated = false
}