//
//  ProfileViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/28.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit

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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor()]
        
        if GitHouseUtils.myProfile != nil {
            configView()
        } else {
            KRProgressHUD.show()
            
            GitHouseUtils.octokit!.me() {[weak self] response in
                dispatch_async(dispatch_get_main_queue(), {
                    
                    guard let strongSelf = self else { return }
                    
                    switch response {
                    case .Success(let user):
                        GitHouseUtils.myProfile = user
                        GitHouseUtils.authenticated = true
                        
                        KRProgressHUD.dismiss()
                        strongSelf.configView()
                    default:
                        KRProgressHUD.showError()
                    }
                })
            }
        }
    }
    
    private func configView() {
        let iconView = UIView()
        iconView.backgroundColor = UIColor.flatWhiteColor()
        view.addSubview(iconView)
        
        iconView.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(64)
            make.height.equalTo(140)
        }
        
        let headerView = UIImageView()
        headerView.layer.cornerRadius = 35
        headerView.layer.masksToBounds = true
        headerView.af_setImageWithURL(NSURL.init(string:(GitHouseUtils.myProfile?.avatarURL)!)!, placeholderImage: UIImage(named: "PlaceHolder"), filter: nil, imageTransition: UIImageView.ImageTransition.FlipFromTop(0.5), runImageTransitionIfCached: true, completion: nil)
        iconView.addSubview(headerView)
        
        headerView.snp_makeConstraints { (make) in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.top.equalTo(15)
            make.centerX.equalTo(iconView)
        }
        
        let nameLabel = UILabel()
        nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        nameLabel.font = UIFont.boldSystemFontOfSize(20)
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.text = GitHouseUtils.myProfile?.name
        iconView.addSubview(nameLabel)
        
        nameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(headerView.snp_bottom)
            make.width.equalTo(100)
            make.centerX.equalTo(iconView)
            make.height.equalTo(30)
        }
        
        
        tableView.tableFooterView = UIView.init()
        tableView.backgroundColor = UIColor.flatWhiteColor()
        tableView.scrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(iconView.snp_bottom)
            make.bottom.equalTo(view.snp_bottom).offset(-44)
        }
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        configCell(cell, forRowAtIndexPath: indexPath)
        cell.userInteractionEnabled = false
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
