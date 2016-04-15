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
    case Owned
    case Stared
}

class RepositoriesViewController: BaseViewController {

    private var repositoriesType: RepositoriesType = RepositoriesType.Owned
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.refreshEnabled = true
        self.tabBarItem = UITabBarItem(title: "Repositories".localized(),
                                       image: UIImage.octiconsImageFor(OcticonsID.Repo, iconColor: UIColor.flatGrayColor(), size: CGSizeMake(25, 25)),
                                       selectedImage: UIImage.octiconsImageFor(OcticonsID.Repo, iconColor: UIColor.flatBlueColor(), size: CGSizeMake(25, 25)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Respositories".localized()
        
        let segmentedControl = UISegmentedControl.init(items: ["Owned".localized(), "Stared".localized()])
        segmentedControl.tintColor = UIColor.flatWhiteColor()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 10
        segmentedControl.addTarget(self, action: #selector(segmentedAction), forControlEvents: UIControlEvents.ValueChanged)
        navigationItem.titleView = segmentedControl
        
        KRProgressHUD.show()
        GitHouseUtils.isHomeLoaded = true
    }
    
    @objc private func segmentedAction(segmentedControl: UISegmentedControl) -> Void {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            repositoriesType = RepositoriesType.Stared
        default:            repositoriesType = RepositoriesType.Owned
        }
        
        KRProgressHUD.show()
        loadData()
    }

}

//MARK: BaseModeProtocol
extension RepositoriesViewController {
    
    override func loadData() {
        
        if !GitHouseUtils.authenticated {
            authenticate()
        } else {
            fetchResponsitories()
        }
    }
    
    private func authenticate() -> Void {
        
        GitHouseUtils.octokit!.me { [weak self](response) in
            guard let strongSelf = self else { return }
            
            switch response {
            case .Success(let user):
                GitHouseUtils.myProfile = user
                
                strongSelf.fetchResponsitories()
                dispatch_async(dispatch_get_main_queue(), { 
                    strongSelf.dismissViewControllerAnimated(true, completion: {})
                })
                
            case .Failure( _):
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    KRProgressHUD.showInfo(progressHUDStyle: nil, maskType: nil, activityIndicatorStyle: nil, font: nil, message: "Authentication Failed".localized())
                    
                    strongSelf.presentViewController(UserLoginViewController(authCompletion:{ (user) in
                        
                        strongSelf.dismissViewControllerAnimated(true, completion: nil)
                        
                        KRProgressHUD.show()
                        strongSelf.fetchResponsitories()
                        
                    }), animated: true, completion: {})
                })
            }
        }
    }
    
    private func fetchResponsitories() -> Void {
        
        GitHouseUtils.octokit!.repositories() { [weak self] (response) in
            
            guard let strongSelf = self else { return }
            
            switch response {
            case .Success( let repositories):
                strongSelf.allItems = repositories
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let repository: Repository = allItems[indexPath.row] as! Repository
        (cell as! RepositoriesTableCellTableViewCell).configCell(repository)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}

