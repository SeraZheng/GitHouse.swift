//
//  BaseNavigationController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/31.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit

class BaseNavigationController: NavigationStack {

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if navigationController?.viewControllers.count == 2 {
            return true
        }
        
        if let navigationController = self.navigationController as? NavigationStack {
            navigationController.showControllers()
        }
        
        return false
    }
}
