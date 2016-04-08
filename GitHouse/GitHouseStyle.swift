//
//  GitHouseStyle.swift
//  GitHouse
//
//  Created by 郑少博 on 16/4/7.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit

public struct GitHouseStyle {
    public static let navigationBarTintColor = UIColor(red: 0/255.0, green: 100.0/255.0, blue: 174.0/255.0, alpha: 1.0)
    
    public static func themeConfig() -> Void {
        
        UINavigationBar.appearance().barTintColor =  navigationBarTintColor
        UINavigationBar.appearance().tintColor = UIColor.flatWhiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false
        )
        
        KRProgressHUD.setDefaultStyle(style: KRProgressHUDStyle.Black)
        KRProgressHUD.setDefaultMaskType(type: KRProgressHUDMaskType.Black)
        KRProgressHUD.setDefaultActivityIndicatorStyle(style: KRProgressHUDActivityIndicatorStyle.White)
    }
}