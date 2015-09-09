//
//  LoginViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKLoginKit

protocol LoginViewControllerDelegate: class {
    func loginDidSucceed(loginController: LoginViewController)
    func loginDidFail(loginController: LoginViewController, error: NSError!)
    func loginWasCancelled(loginController: LoginViewController)
}

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton?
    
    weak var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton!.readPermissions = ["public_profile"]
        fbLoginButton?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //println("Downloaded access token for userId \(result.token.userID) with value \(result.token.tokenString)")
        if error != nil {
            self.delegate?.loginDidFail(self, error: error)
        } else if result.isCancelled {
            self.delegate?.loginWasCancelled(self)
        } else {
            findUserByFBToken(result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // TODO: support logout
    }
    
    
    // MARK: - Generic Selectors
    
    @IBAction func backButtonClick(sender: AnyObject?) {
        self.delegate?.loginWasCancelled(self)
    }
    
    func findUserByFBToken(fbToken: String) {
        MainUser.loginWithFBToken { (err) -> Void in
            if err == nil {
                self.delegate?.loginDidSucceed(self)
            } else {
                println("findUserByFBToken error \(err)")
                self.delegate?.loginDidFail(self, error: err)
            }
        }
    }
}
