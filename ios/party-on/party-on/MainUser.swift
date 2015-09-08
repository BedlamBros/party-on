//
//  MainUser.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias MainUserLoginCallback = (err: NSError?) -> Void


class MainUser: User {
    
    static var sharedInstance: MainUser? = nil
    
    class func loginWithFBToken(callback: MainUserLoginCallback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let dummyUserJson = JSON([
                "_id": "55e7c1ea764a112d788dbd1d",
                "username": "16f89c748b126841"
            ])
            MainUser.sharedInstance = MainUser(json: dummyUserJson)
            //MainUser.sharedInstance?.fbToken =
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                return callback(err: nil)
            })
        })
    }
}
