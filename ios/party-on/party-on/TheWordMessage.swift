//
//  TheWordMessage.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/9/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SwiftyJSON

class TheWordMessage: NSObject, ServerModel {
    
    var oID: String?
    var body: String!
    var created: NSDate!
    
    required init(json: JSON) {
        super.init()
        self.oID = json["_id"].string
        self.created = NSDate(timeIntervalSince1970: json["created"].numberValue.doubleValue / 1000)
        self.body = json["body"].stringValue
    }
    
    init(oID: String?, body: String, created: NSDate) {
        super.init()
        self.oID = oID
        self.body = body
        self.created = created
    }
    
    func toJSON() -> JSON {
        var json = JSON([
            "body": body
        ])
        
        if let oid = self.oID {
            json["_id"] = JSON(oid)
        }
        return json
    }
}
