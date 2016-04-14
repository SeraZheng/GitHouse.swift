//
//  Authentication.swift
//  GitHouse
//
//  Created by 郑少博 on 16/4/13.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import Foundation

public enum Authentication {
    
    case WebFlow
    case NativeFlow
    
    public static var userToken: String?
}