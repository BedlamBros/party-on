//
//  UniversityPickerController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit

class UniversityPickerController: UIViewController {
    
    @IBOutlet weak var indianaUniversityButton: UIButton?
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var logInOutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let preferredUniversity = University.getStoredUniversityPreference() {
            // bypass this controller if university preference is already set
            University.currentUniversity = preferredUniversity
            if let searchPartiesController = self.storyboard?.instantiateViewControllerWithIdentifier(searchPartyStoryboardIdentifier) as? PartySearchViewController {
                self.navigationController?.pushViewController(searchPartiesController, animated: false)
            }
        }
        
        self.logInOutButton?.addTarget(self, action: "loginLogoutClick", forControlEvents: .TouchUpInside)
        updateLoginLogoutButtonTitle()
        
        self.backgroundImageView?.contentMode = UIViewContentMode.ScaleToFill
        
        // Configure Indiana University button
        self.indianaUniversityButton?.layer.cornerRadius = 5
        self.indianaUniversityButton?.clipsToBounds = true
        
        // Configure title label
        let viewFrame = self.backgroundImageView!.frame
        let titleFrameVertPercentage: CGFloat = 0.1
        let titleFrameSideMargin: CGFloat = 0.05 * viewFrame.width
        let titleLabel = UILabel(frame: CGRectMake(titleFrameSideMargin, UIApplication.sharedApplication().statusBarFrame.height, viewFrame.width - (2 * titleFrameSideMargin), viewFrame.height * titleFrameVertPercentage))
        titleLabel.text = "Pick your University"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Courier-Bold", size: 20)
        self.backgroundImageView!.addSubview(titleLabel)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        updateLoginLogoutButtonTitle()
    }
    
    @IBAction func selectUniversity(sender: UIView) {
        if sender === self.indianaUniversityButton {
            University.currentUniversity = University.universityForType(UniversityType.IndianaUniversity)
            self.performSegueWithIdentifier(enterAppSegueIdentifier, sender: self)
        }
    }
    
    func loginLogoutClick() {
        let alertUserOfLoginError = { () -> Void in
            UIAlertView(title: "Oops", message: "Wasn't able to log in", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        if MainUser.storedUserId == nil {
            // logging in
            FBSDKLoginManager().logInWithReadPermissions(["public_profile"], handler: { (result: FBSDKLoginManagerLoginResult!, err: NSError!) -> Void in
                if err != nil {
                    alertUserOfLoginError()
                } else if result.isCancelled {
                    // login was cancelled, ignore
                } else {
                    SVProgressHUD.showAndBlockInteraction(self.view)
                    MainUser.loginWithFBToken({ (err) -> Void in
                        SVProgressHUD.dismissAndUnblockInteraction(self.view)
                        if err != nil {
                            alertUserOfLoginError()
                        } else {
                            self.updateLoginLogoutButtonTitle()
                            UIAlertView(title: "Welcome to Hangloose", message: "Now that you're logged in, you can create your own parties.", delegate: nil, cancelButtonTitle: "Ok").show()
                            MainUser.checkForBannedStatus(nil)
                        }
                    })
                }
            })
        } else {
            // logging out
            MainUser.sharedInstance?.logout()
            self.updateLoginLogoutButtonTitle()
            UIAlertView(title: "Success", message: "You've been logged out", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    private func updateLoginLogoutButtonTitle() {
        self.logInOutButton?.setTitle(MainUser.storedUserId == nil ? "Login" : "Logout", forState: .Normal)
    }
    
    private let enterAppSegueIdentifier = "EnterAppSegueAnimated"
    private let searchPartyStoryboardIdentifier = "SearchPartiesController"
}
