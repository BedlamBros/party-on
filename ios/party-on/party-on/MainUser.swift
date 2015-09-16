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

typealias MainUserLoginCallback = (err: NSError?) -> Void


class MainUser: User {
    
    static var sharedInstance: MainUser? = nil
    private static let httpManager = AFHTTPRequestOperationManager()
    
    class func loginWithFBToken(callback: MainUserLoginCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let syncCallback: MainUserLoginCallback = { (err: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let user = self.sharedInstance
                    return callback(err: err)
                })
            }
            
            MainUser.sharedInstance = MainUser()
            if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                self.sharedInstance?.fbUserId = fbAccessToken.userID
                self.sharedInstance?.fbToken = fbAccessToken.tokenString
            }
            let endpoint = API_ROOT + "/auth/facebook/getorcreate"
            var params: NSDictionary? = nil
            if let fbJson = self.sharedInstance?.facebookJSON()?.dictionaryObject {
                params = fbJson
            }
            
            self.httpManager.POST(endpoint, parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                // success
                self.sharedInstance = MainUser(json: JSON(response))
                return syncCallback(err: nil)
                }, failure: { (operation: AFHTTPRequestOperation, err: NSError) -> Void in
                // failure
                    
                let reqBody = JSON(operation.request.HTTPBody!)
                return syncCallback(err: err)
            })
        })
    }
}
