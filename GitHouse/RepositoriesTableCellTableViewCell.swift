//
//  RepositoriesTableCellTableViewCell.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/31.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import Octokit

public class RepositoriesTableCellTableViewCell: UITableViewCell {

    private var iconView: UIImageView?
    private var titleLabel: UILabel?
    private var descriptionLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        iconView = UIImageView(image: UIImage(named: "PlaceHolder"))
        iconView!.contentMode = UIViewContentMode.ScaleToFill
        contentView.addSubview(iconView!)
        
        titleLabel = UILabel()
        titleLabel!.numberOfLines = 1
        titleLabel!.font = UIFont.boldSystemFontOfSize(20)
        titleLabel!.textColor = UIColor.flatBlueColorDark()
        titleLabel!.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 80
        contentView.addSubview(titleLabel!)
        
        descriptionLabel = UILabel()
        descriptionLabel!.numberOfLines = 2
        descriptionLabel!.font = UIFont.systemFontOfSize(14)
        descriptionLabel!.textColor = UIColor.lightGrayColor()
        descriptionLabel!.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 80
        contentView.addSubview(descriptionLabel!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        
        titleLabel?.text = ""
        descriptionLabel?.text = ""
        imageView?.af_cancelImageRequest()
        imageView?.image = nil
        
        super.prepareForReuse()
    }
    
    override public func updateConstraints() {
        
        iconView!.snp_makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.right.equalTo(-10)
            make.top.equalTo(5)
        }
        
        titleLabel!.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(iconView!)
            make.right.equalTo((iconView?.snp_left)!).offset(-10)
            make.height.equalTo(20)
        }
        
        descriptionLabel!.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel!)
            make.right.equalTo(titleLabel!)
            make.top.equalTo(titleLabel!.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom).offset(-5)
        }
        
        super.updateConstraints()
    }
    
    public func configCell(repositories: Repository) -> Void {
        iconView!.af_setImageWithURL(NSURL.init(string: repositories.owner.avatarURL!)!)
        titleLabel!.text = repositories.name
        descriptionLabel!.text = repositories.repositoryDescription
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
}
