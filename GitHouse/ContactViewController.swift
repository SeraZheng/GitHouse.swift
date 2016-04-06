//
//  DiscoverViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/28.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit

enum ContactType{
    case followers
    case followings
}

class ContactViewController: BaseViewController {

    var contactType: ContactType = ContactType.followers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.refreshEnabled = true

        self.tabBarItem = UITabBarItem(title: "Contact".localized(), image: UIImage(named: "Discover"), selectedImage: UIImage(named: "DiscoverHighlighted"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.flatWhiteColor()
        
        let segmentedControl = UISegmentedControl.init(items: ["Followers".localized(), "Followings".localized()])
        segmentedControl.tintColor = UIColor.flatWhiteColor()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 10
        segmentedControl.addTarget(self, action: #selector(segmentedAction), forControlEvents: UIControlEvents.ValueChanged)
        navigationItem.titleView = segmentedControl
        loadingView.startAnimation()
    }
    
    @objc private func segmentedAction(segmentedControl: UISegmentedControl) -> Void {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            contactType = ContactType.followings
        default:
            contactType = ContactType.followers
        }
        
        loadingView.startAnimation()
        loadData()
    }
}

//MARK: Data
extension ContactViewController {
    override func loadData() {
        weak var weakSelf = self

        switch contactType {
        case ContactType.followings:
            Octokit(GitHouseUtils.sharedInstance.config).myFollowing({ (response) in
                let strongSelf = weakSelf
                
                switch response {
                case .Success( let contacts):
                    strongSelf!.allItems = contacts
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf?.loadingView.stopAnimation()
                        strongSelf?.tableView.reloadData()
                    })
                    
                case .Failure( _):
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf?.modelDelegate?.showError!()
                    })
                }
            })
        default:
            Octokit(GitHouseUtils.sharedInstance.config).myFollowers { (response) in
                
                let strongSelf = weakSelf
                
                switch response {
                case .Success( let contacts):
                    strongSelf!.allItems = contacts
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf?.loadingView.stopAnimation()
                        strongSelf?.tableView.reloadData()
                    })
                    
                case .Failure( _):
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf?.loadingView.stopAnimation()
                        strongSelf?.modelDelegate?.showError!()
                    })
                }
            }
        }
        
    }
}

extension ContactViewController {
    override func cellClass() -> UITableViewCell.Type {
        return ContactsTableCell.self
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let user: User = allItems[indexPath.row] as! User
        (cell as! ContactsTableCell).configCell(user)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

}