//
//  User.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, ServerModel {
    
    var oID: String?
    var fbToken: String?
    var fbUserId: String?
    var username: String?
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init()
        self.oID = json["_id"].stringValue
        self.username = json["username"].string
        if let fbJson = json["facebook"].dictionary {
            self.fbToken = fbJson["accessToken"]?.string
            self.fbUserId = fbJson["userId"]?.string
        }
    }
    
    func toJSON() -> JSON {
        var json = JSON([])
        if let uname = self.username {
            json["username"] = JSON(uname)
        }
        if let fb = facebookJSON() {
            json["facebook"] = fb
        }
        if let oid = self.oID {
            json["_id"] = JSON(oid)
        }
        return json
    }
    
    func facebookJSON() -> JSON? {
        if fbToken == nil || fbUserId == nil {
            return nil
        }
        return JSON([
            "user_id": fbUserId!,
            "access_token": fbToken!
        ])
    }
}
