//
//  IssueViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/4/13.
//  Copyright © 2016年 郑少博. All rights reserved.
//

//
//  RepositoriesViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/28.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit
import AlamofireImage

class IssuesViewController: BaseViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.refreshEnabled = true
        self.tabBarItem = UITabBarItem(title: "Issues".localized(),
                                       image: UIImage.octiconsImageFor(OcticonsID.IssueOpened, iconColor: UIColor.flatGrayColor(), size: CGSizeMake(25, 25)),
                                       selectedImage: UIImage.octiconsImageFor(OcticonsID.IssueOpened, iconColor: UIColor.flatBlueColor(), size: CGSizeMake(25, 25)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Issues".localized()
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        KRProgressHUD.show()
        GitHouseUtils.isHomeLoaded = true
    }
}

//MARK: BaseModeProtocol
extension IssuesViewController {
    
    override func loadData() {
        
       GitHouseUtils.octokit?.myIssues(completion: { [weak self] (response) in
        guard let strongSelf = self else { return }
        
        switch response {
        case .Success( let issues):
            strongSelf.allItems = issues
            dispatch_async(dispatch_get_main_queue(), {
                KRProgressHUD.dismiss()
                strongSelf.tableView.reloadData()
            })
            
        case .Failure( _):
            dispatch_async(dispatch_get_main_queue(), {
                KRProgressHUD.dismiss()
                strongSelf.modelDelegate?.showError!()
            })
        }
       })
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension  IssuesViewController {
    
    override func cellClass() -> UITableViewCell.Type {
        return IssueTableCell.self
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let issue: Issue = allItems[indexPath.row] as! Issue
        (cell as! IssueTableCell).configCell(issue)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}

