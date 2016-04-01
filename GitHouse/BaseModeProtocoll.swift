//
//  BaseModel.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/30.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import Foundation

@objc public protocol BaseModelProtocol: NSObjectProtocol {
    
    func loadData() -> Void
    
    optional func loadMore(refresh: Bool) -> Void
    optional func showError() -> Void
    optional func showEmpty() -> Void
}