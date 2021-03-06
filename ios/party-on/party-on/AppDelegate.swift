//
//  AppDelegate.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    weak var partyDetailControllerInFocus: PartyDetailViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.partyDetailControllerInFocus?.descheduleRefreshParty()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        print(MainUser.sharedInstance?.oID)
        if MainUser.sharedInstance?.oID == nil {
            // Attempt to login if a token exists already and not logged in
            MainUser.loginWithFBToken { (err) -> Void in
            }
        }
        self.partyDetailControllerInFocus?.scheduleRefreshParty()
        
        // Check for EULA acceptance
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let didAcceptEULA = userDefaults.boolForKey(AppDelegate.didAcceptEULADefaultsKey)
        if !didAcceptEULA {
            // Force the EULA acceptance
            let eulaController = EULAViewController(nibName: "EULAViewController", bundle: NSBundle.mainBundle())
            self.window?.rootViewController?.presentViewController(eulaController, animated: true, completion: nil)
        } else {
            // check for banned status immediately
            self.checkForBanned()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func checkForBanned() {
        MainUser.checkForBannedStatus { (isBanned) -> Void in
            if isBanned {
                let alert = UIAlertController(title: "Sorry", message: "Your account has been banned for inappropriate content", preferredStyle: UIAlertControllerStyle.Alert)
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    static let didAcceptEULADefaultsKey = "did-accept-eula"
}

