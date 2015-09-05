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
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            self.delegate?.loginDidFail(self, error: error)
        } else if result.isCancelled {
            self.delegate?.loginWasCancelled(self)
        } else {
            self.delegate?.loginDidSucceed(self)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // TODO: support logout
    }
    
    
    // MARK: - Generic Selectors
    
    @IBAction func backButtonClick(sender: AnyObject?) {
        self.delegate?.loginWasCancelled(self)
    }
}
