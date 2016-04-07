//
//  BaseViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/29.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DGElasticPullToRefresh

public class BaseViewController: UIViewController {

    public var refreshEnabled = false
    public var allItems: Array<AnyObject> = []
    public let tableView = UITableView()
    weak var modelDelegate: BaseModelProtocol?
    lazy var loadingView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRectZero,type: NVActivityIndicatorType.BallClipRotate, color: UIColor.flatOrangeColor(), size: CGSizeMake(60, 60))
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modelDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.flatWhiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor()]
        
        tableView.backgroundColor = UIColor.flatWhiteColor()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        view.addSubview(loadingView)
        loadingView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
        
        if refreshEnabled {
            let refreshLoadingView = DGElasticPullToRefreshLoadingViewCircle()
            refreshLoadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
            
            tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () in
                self?.loadData()
                self?.tableView.dg_stopLoading()
                }, loadingView: refreshLoadingView)
            
            tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
            tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        modelDelegate?.loadData()
    }
}

//MARK: BaseModelProtocol
extension BaseViewController: BaseModelProtocol {
    
    public func loadData() {
        // overriden by subclass
    }
    
    public func loadMore(refresh: Bool) {
        // overriden by subclass
    }
    
    public func showError() {
        // overriden by subclass
    }
}

//MARK: UITableViewDataSource
extension BaseViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "GitHouse"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = cellClass().init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        return cell!
    }
    
    public func cellClass() -> UITableViewCell.Type {
        return UITableViewCell.self
    }
}

//MARK: UITableViewDelegate
extension BaseViewController: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
