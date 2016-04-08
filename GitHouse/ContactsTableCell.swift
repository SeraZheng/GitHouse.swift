//
//  ContactsTableCell.swift
//  GitHouse
//
//  Created by 郑少博 on 16/4/5.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit

public class ContactsTableCell: UITableViewCell {

    private var iconView: UIImageView?
    private var titleLabel: UILabel?
    private var descriptionLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        iconView = UIImageView(image: UIImage(named: "PlaceHolder"))
        iconView!.contentMode = UIViewContentMode.ScaleToFill
        iconView?.layer.masksToBounds = true
        iconView?.layer.cornerRadius = 20
        contentView.addSubview(iconView!)
        
        titleLabel = UILabel()
        titleLabel!.numberOfLines = 2
        titleLabel!.font = UIFont.boldSystemFontOfSize(20)
        titleLabel!.textColor = UIColor.flatBlueColorDark()
        titleLabel!.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 80
        contentView.addSubview(titleLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        
        titleLabel?.text = ""
        iconView?.image = UIImage(named: "PlaceHolder")
        iconView?.af_cancelImageRequest()
        
        super.prepareForReuse()
    }
    
    override public func updateConstraints() {
        
        iconView!.snp_makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.left.equalTo(10)
            make.top.equalTo(5)
        }
        
        titleLabel!.snp_makeConstraints { (make) in
            make.left.equalTo((iconView?.snp_right)!).offset(20)
            make.top.equalTo(iconView!)
            make.right.equalTo(contentView).offset(-10)
            make.height.equalTo(iconView!)
        }
        
        super.updateConstraints()
    }
    
    public func configCell(user: User) -> Void {
        iconView!.af_setImageWithURL(NSURL.init(string: user.avatarURL!)!)
        titleLabel!.text = user.login
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
}
