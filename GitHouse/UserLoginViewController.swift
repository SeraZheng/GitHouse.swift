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
import Alamofire
import Spring

class UserLoginViewController: UIViewController, UITextFieldDelegate {

    private let logoView = UIImageView(image: UIImage(named: "Logo"))
    private let usernameField = YoshikoTextField()
    private let passwordField = YoshikoTextField()
    private let loginButton = SpringButton(frame: CGRectZero)
    private let authenticateButton = UIButton(frame: CGRectZero)
    private var authCompletion:(() ->Void)?
    
    init(authCompletion:() -> Void) {
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
        usernameField.returnKeyType = UIReturnKeyType.Next
        usernameField.activeBorderColor = UIColor.flatOrangeColor()
        usernameField.inactiveBorderColor = UIColor.flatWhiteColor()
        usernameField.placeholder = "Please input your username or email".localized()
        usernameField.placeholderColor = UIColor.flatBlackColor()
        usernameField.delegate = self
        view.addSubview(usernameField)
        
        usernameField.snp_makeConstraints { (make) in
            make.top.equalTo(logoView.snp_bottom).offset(20)
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.height.equalTo(60)
        }
        
        passwordField.clearButtonMode = UITextFieldViewMode.WhileEditing
        passwordField.backgroundColor = UIColor.whiteColor()
        passwordField.minimumFontSize = 19
        passwordField.returnKeyType = UIReturnKeyType.Done
        passwordField.secureTextEntry = true
        passwordField.activeBorderColor = UIColor.flatOrangeColor()
        passwordField.inactiveBorderColor = UIColor.flatWhiteColor()
        passwordField.placeholder = "Please input your password".localized()
        passwordField.placeholderColor = UIColor.flatBlackColor()
        passwordField.delegate = self
        view.addSubview(passwordField)
        
        passwordField.snp_makeConstraints { (make) in
            make.top.equalTo(usernameField.snp_bottom).offset(20)
            make.left.equalTo(usernameField)
            make.right.equalTo(usernameField)
            make.height.equalTo(usernameField)
        }
        
        loginButton.enabled = false
        loginButton.backgroundColor = UIColor.flatGrayColor()
        loginButton.layer.cornerRadius = 5
        loginButton.setTitle("Login".localized(), forState: UIControlState.Normal)
        loginButton.addTarget(self, action: #selector(loginAction), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(loginButton)
        
        loginButton.snp_makeConstraints { (make) in
            make.top.equalTo(passwordField.snp_bottom).offset(20)
            make.left.equalTo(usernameField)
            make.right.equalTo(usernameField)
            make.height.equalTo(40)
        }
        
        authenticateButton.backgroundColor = view.backgroundColor
        authenticateButton.titleLabel?.textAlignment = NSTextAlignment.Center
        authenticateButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        authenticateButton.setTitle("Authenticated by Web Application".localized(), forState: UIControlState.Normal)
        authenticateButton.setTitleColor(UIColor.flatBlueColor(), forState: UIControlState.Normal)
        authenticateButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        authenticateButton.addTarget(self, action: #selector(authenticateAction), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(authenticateButton)
        
        authenticateButton.snp_makeConstraints { (make) in
            make.width.equalTo(loginButton)
            make.height.equalTo(loginButton)
            make.bottom.equalTo(view).offset(-20)
            make.centerX.equalTo(view)
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
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        KRProgressHUD.show(progressHUDStyle: KRProgressHUDStyle.Black, maskType: KRProgressHUDMaskType.Clear, activityIndicatorStyle: KRProgressHUDActivityIndicatorStyle.White, font: nil, message: "Authenticating...".localized(), image: nil)
        
        authorizate()
    }
    
    private func authorizate() {
        
        let username = usernameField.text!
        let password = passwordField.text!
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSASCIIStringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let authorizationHeaderStr = "Basic \(base64LoginString)"
        
        Alamofire.request(.PUT, "https://api.github.com/authorizations/clients/\(GitHouseUtils.oAuthToken)", parameters: ["scopes": GitHouseUtils.oAuthScopes, "client_secret": GitHouseUtils.oAuthSecret], encoding: ParameterEncoding.JSON, headers: ["Authorization": authorizationHeaderStr])
            .response { [weak self] request, response, data, error in
                
                guard let strongSelf = self else { return }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if response?.statusCode != 200 && response?.statusCode != 201{
                        strongSelf.loginButton.animation = "shake"
                        strongSelf.loginButton.animate()
                        
                        KRProgressHUD.dismiss()
                    } else {
                        do {
                            let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                            
                            let token = result["token"] as? String
                            if token?.characters.count == 0 {
                                
                                Alamofire.request(.DELETE, "https://api.github.com/authorizations/\(result["id"]!)", parameters: nil, encoding: .JSON, headers: ["Authorization": authorizationHeaderStr]).response(completionHandler: { (_, _, _, _) in
                                    
                                    strongSelf.authorizate()
                                })
                                
                                return
                            }
                            
                            KRProgressHUD.dismiss()
                            
                            GitHouseUtils.accessToken = token
                            GitHouseUtils.authenticated = true
                            
                            strongSelf.authCompletion!()
                        } catch {
                            fatalError()
                        }
                    }
                })
        }
    }
    
    //MARK:AuthenticateAction
    
    func authenticateAction() -> Void {
        UIApplication.sharedApplication().openURL(GitHouseUtils.oAuthConfig.authenticate()!)
    }
    
    //MARK:UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string.characters.count == 0 && range.location == 0 {
            loginButton.backgroundColor = UIColor.flatGrayColor()
            loginButton.enabled = false
        }
        else if textField == usernameField && passwordField.text?.characters.count > 0 ||
                textField == passwordField && usernameField.text?.characters.count > 0{
            
            loginButton.backgroundColor = UIColor.flatOrangeColor()
            loginButton.enabled = true
        }
        
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue()) {
            self.loginButton.enabled = false
            self.loginButton.backgroundColor = UIColor.flatGrayColor()
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard textField == passwordField else { passwordField.becomeFirstResponder(); return false}
        
        textField.resignFirstResponder()
        return true
    }
    
}
