//
//  MainUser.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import FBSDKCoreKit
import FBSDKLoginKit

typealias MainUserLoginCallback = (err: NSError?) -> Void
typealias MainUserIsBannedCallback = (isBanned: Bool) -> Void


class MainUser: User {
    
    static var sharedInstance: MainUser? = nil
    private static let httpManager = AFHTTPRequestOperationManager()
    
    static var storedUserId: String? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.stringForKey(storedUserIdDefaultsKey)
        } set {
            let val = newValue
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if val != nil {
                // setting the id
                userDefaults.setObject(val, forKey: storedUserIdDefaultsKey)
            } else {
                // deleting the id
                userDefaults.removeObjectForKey(storedUserIdDefaultsKey)
            }
            userDefaults.synchronize()
        }
    }
    
    func logout() {
        MainUser.storedUserId = nil
        FBSDKLoginManager().logOut()
    }
    
    class func loginWithFBToken(callback: MainUserLoginCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let syncCallback: MainUserLoginCallback = { (err: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    _ = self.sharedInstance
                    return callback(err: err)
                })
            }
            
            MainUser.sharedInstance = MainUser()
            if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                self.sharedInstance?.fbUserId = fbAccessToken.userID
                self.sharedInstance?.fbToken = fbAccessToken.tokenString
            }
            let __token = FBSDKAccessToken.currentAccessToken()
            print("current fb access token is \(__token?.tokenString)")
            let endpoint = API_ROOT + "/auth/facebook/getorcreate"
            var params: NSDictionary? = nil
            if let fbJson = self.sharedInstance?.facebookJSON()?.dictionaryObject {
                params = fbJson
            }
            
            self.httpManager.POST(endpoint, parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                // success
                self.sharedInstance = MainUser(json: JSON(response))
                self.storedUserId = self.sharedInstance?.oID
                
                return syncCallback(err: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
                // failure
                return syncCallback(err: err)
            })
        })
    }
    
    class func checkForBannedStatus(callback: MainUserIsBannedCallback?) {
        if let _ = MainUser.storedUserId {
            // we do have a stored user, check it
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                let syncCallback: MainUserIsBannedCallback = { (isBanned: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        return callback?(isBanned: isBanned)
                    })
                }
                
                let endpoint = API_ROOT + "/users/bannedstatus"
                self.applyAuthHeaders(self.httpManager)
                self.httpManager.GET(endpoint, parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                    return syncCallback(isBanned: JSON(response)["banned"].boolValue)
                    }, failure: { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
                        // failed to ascertain if the user was banned, default to not banning them
                        return syncCallback(isBanned: false)
                })
            })
        } else {
            // we can't identify the user, so they can't be banned
            callback?(isBanned: false)
        }
    }
    
    class func applyAuthHeaders(httpManager: AFHTTPRequestOperationManager) {
        if let fbToken = FBSDKAccessToken.currentAccessToken() {
            httpManager.requestSerializer.setValue("Bearer " + fbToken.tokenString, forHTTPHeaderField: "Authorization")
            httpManager.requestSerializer.setValue("facebook", forHTTPHeaderField: "Passport-Auth-Strategy")
        }
    }
    
    private static let storedUserIdDefaultsKey = "stored-user-id"
}
