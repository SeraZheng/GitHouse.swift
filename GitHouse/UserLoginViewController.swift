//
//  UserLoginViewController.swift
//  GitHouse
//
//  Created by 郑少博 on 16/3/25.
//  Copyright © 2016年 郑少博. All rights reserved.
//

import UIKit
import TextFieldEffects
import Localize_Swift
import SnapKit
import ChameleonFramework
import Octokit
import KeychainAccess

class UserLoginViewController: UIViewController, UITextFieldDelegate {

    private let logoView = UIImageView.init(image: UIImage.init(named: "Logo"))
    private let usernameField = YoshikoTextField()
    private let loginButton = TKTransitionSubmitButton.init(frame: CGRectZero)
    private var authCompletion:((user: User) ->Void)?
    
    init(authCompletion:(user: User) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.authCompletion = authCompletion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(logoView)
        
        logoView.snp_makeConstraints { (make) in
            make.top.equalTo(40)
            make.centerX.equalTo(view)
            make.width.equalTo(180)
            make.height.equalTo(180)
        }
        
        usernameField.clearButtonMode = UITextFieldViewMode.WhileEditing
        usernameField.backgroundColor = UIColor.whiteColor()
        usernameField.minimumFontSize = 19
        usernameField.returnKeyType = UIReturnKeyType.Done
        usernameField.activeBorderColor = UIColor.flatOrangeColor()
        usernameField.inactiveBorderColor = UIColor.flatWhiteColor()
        usernameField.placeholder = "Please input your Access Token".localized()
        usernameField.placeholderColor = UIColor.flatBlackColor()
        usernameField.delegate = self
        view.addSubview(usernameField)
        
        usernameField.snp_makeConstraints { (make) in
            make.top.equalTo(logoView.snp_bottom).offset(20)
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.height.equalTo(60)
        }
        
        loginButton.enabled = false
        loginButton.normalBackgroundColor = UIColor.flatGrayColor()
        loginButton.highlightedBackgroundColor = UIColor.flatOrangeColor()
        loginButton.layer.cornerRadius = 5
        loginButton.setTitle("Login".localized(), forState: UIControlState.Normal)
        loginButton.addTarget(self, action: #selector(loginAction), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(loginButton)
        
        loginButton.snp_makeConstraints { (make) in
            make.top.equalTo(usernameField.snp_bottom).offset(20)
            make.left.equalTo(usernameField)
            make.right.equalTo(usernameField)
            make.height.equalTo(40)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK:KeyboardNotification
    
    func keyboardWillShow(notification: NSNotification) -> Void {
        
        let duration: NSTimeInterval = (notification.userInfo! as NSDictionary)[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        UIView.animateWithDuration(2*duration) {
            self.logoView.snp_updateConstraints { (make) in
                make.top.equalTo(0)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) -> Void {
        
        let duration: NSTimeInterval = (notification.userInfo! as NSDictionary)[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        UIView.animateWithDuration(2*duration) {
            self.logoView.snp_updateConstraints { (make) in
                make.top.equalTo(40)
            }
            self.view.layoutIfNeeded()
        }
    }

    //MARK:LoginAction
    
    func loginAction() -> Void {
        
        loginButton.startLoadingAnimation()
        
        let config = TokenConfiguration(usernameField.text)
        
        Octokit(config).me() {[weak self] response in
            dispatch_async(dispatch_get_main_queue(), {
                
                guard let strongSelf = self else { return }
                
                switch response {
                case .Success(let user):
                    GitHouseUtils.accessToken = strongSelf.usernameField.text
                    GitHouseUtils.myProfile = user
                    
                    strongSelf.loginButton.startFinishAnimation(0.5, completion: {
                        GitHouseUtils.authenticated = true
                        strongSelf.authCompletion!(user: user)
                    })

                case .Failure( _):
                    strongSelf.loginButton.spiner.stopAnimation()
                    strongSelf.loginButton.returnToOriginalState()
                }
            })
        }
    }
    
    //MARK:UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string.characters.count == 0 && range.location == 0 {
            loginButton.normalBackgroundColor = UIColor.flatGrayColor()
            loginButton.enabled = false
        }
        else {
            loginButton.normalBackgroundColor = UIColor.flatOrangeColor()
            loginButton.enabled = true
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue()) {
            self.loginButton.enabled = false
            self.loginButton.normalBackgroundColor = UIColor.flatGrayColor()
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
