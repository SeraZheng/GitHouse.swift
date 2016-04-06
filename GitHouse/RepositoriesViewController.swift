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

enum RepositoriesType {
    case owned
    case stared
}

class RepositoriesViewController: BaseViewController {

    private var repositoriesType: RepositoriesType = RepositoriesType.owned
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.refreshEnabled = true
        self.tabBarItem = UITabBarItem(title: "Repositories".localized(), image: UIImage(named: "Repositories"), selectedImage: UIImage(named: "RepositoriesHighlighted"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Respositories".localized()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let segmentedControl = UISegmentedControl.init(items: ["Owned".localized(), "Stared".localized()])
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
            repositoriesType = RepositoriesType.stared
        default:
            repositoriesType = RepositoriesType.owned
        }
        
        loadingView.startAnimation()
        loadData()
    }

}

//MARK: BaseModeProtocol
extension RepositoriesViewController {
    
    override func loadData() {
        
        if !GitHouseUtils.sharedInstance.authenticated {
            authenticate()
        } else {
            fetchResponsitories()
        }
    }
    
    private func authenticate() -> Void {
        weak var weakSelf = self
        Octokit(GitHouseUtils.sharedInstance.config).me { (response) in
            let strongSelf = weakSelf
            
            switch response {
            case .Success(let user):
                GitHouseUtils.myProfile = user
                
                strongSelf?.fetchResponsitories()
                dispatch_async(dispatch_get_main_queue(), { 
                    strongSelf?.dismissViewControllerAnimated(true, completion: {})
                })
                
            case .Failure( _):
                
                dispatch_async(dispatch_get_main_queue(), { 
                    strongSelf!.presentViewController(UserLoginViewController(authCompletion:{ (user) in
                        strongSelf?.loadingView.stopAnimation()
                        strongSelf?.fetchResponsitories()
                        
                        strongSelf?.dismissViewControllerAnimated(true, completion: {
                            strongSelf?.loadingView.startAnimation()
                        })
                    }), animated: true, completion: {})
                })
            }
        }
    }
    
    private func fetchResponsitories() -> Void {
        weak var weakSelf = self
        
        switch repositoriesType {
        case RepositoriesType.stared:
            Octokit(GitHouseUtils.sharedInstance.config).myStars({ (response) in
                let strongSelf = weakSelf
                
                switch response {
                case .Success( let repositories):
                    strongSelf!.allItems = repositories
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
            Octokit(GitHouseUtils.sharedInstance.config).repositories() { response in
                
                let strongSelf = weakSelf
                
                switch response {
                case .Success( let repositories):
                    strongSelf!.allItems = repositories
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

//MARK: UITableViewDataSource, UITableViewDelegate
extension RepositoriesViewController {
    
    override func cellClass() -> UITableViewCell.Type {
        return RepositoriesTableCellTableViewCell.self
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let repository: Repository = allItems[indexPath.row] as! Repository
        (cell as! RepositoriesTableCellTableViewCell).configCell(repository)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}

