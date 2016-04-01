//
//  ProfileViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/28.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit
import RAMAnimatedTabBarController

class ProfileViewController: UIViewController {

    private let tableView = UITableView.init()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Profile".localized(), image: UIImage(named: "Profile"), selectedImage: UIImage(named: "ProfileHighlighted"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Profile".localized()
        view.backgroundColor = UIColor.flatWhiteColor()
        
        
        tableView.tableFooterView = UIView.init()
        tableView.backgroundColor = UIColor.flatWhiteColor()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        let headerView = UIImageView()
        headerView.af_setImageWithURL(NSURL.init(string:(GitHouseUtils.myProfile?.avatarURL)!)!, placeholderImage: UIImage(named: "PlaceHolder"), filter: nil, imageTransition: UIImageView.ImageTransition.FlipFromTop(0.5), runImageTransitionIfCached: true, completion: nil)
        tableView.tableHeaderView = headerView
        
        headerView.snp_makeConstraints { (make) in
            make.left.equalTo(tableView)
            make.right.equalTo(tableView)
            make.top.equalTo(tableView)
            make.height.equalTo(60)
        }
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ProfileCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    private func configCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            cell.imageView?.image = UIImage.octiconsImageFor(OcticonsID.Organization, iconColor: UIColor.flatBlueColor(), size: CGSizeMake(30, 30))
            cell.textLabel?.text = GitHouseUtils.myProfile?.company
        case 1:
            cell.imageView?.image = UIImage.octiconsImageFor(OcticonsID.Location, iconColor: UIColor.flatGreenColor(), size: CGSizeMake(30, 30))
            cell.textLabel?.text = GitHouseUtils.myProfile?.location
        case 2:
            cell.imageView?.image = UIImage.octiconsImageFor(OcticonsID.Mail, iconColor: UIColor.purpleColor(), size: CGSizeMake(30, 30))
            cell.textLabel?.text = GitHouseUtils.myProfile?.email
        case 3:
            cell.imageView?.image = UIImage.octiconsImageFor(OcticonsID.Link, iconColor: UIColor.flatMintColor(), size: CGSizeMake(30, 30))
            cell.textLabel?.text = GitHouseUtils.myProfile?.blog
        default:
            print(cell)
        }
    }
}
