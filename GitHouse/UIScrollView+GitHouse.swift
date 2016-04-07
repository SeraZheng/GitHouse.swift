//
//  UIScrollView+GitHouse.swift
//  GitHouse
//
//  Created by 郑少博 on 16/4/7.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit

//MARK: Fix bug of DGElasticPullToRefresh
extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}
