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
    }
    
    init(oID: String, body: String, created: NSDate) {
        super.init()
        self.oID = oID
        self.body = body
        self.created = created
    }
    
    func toJSON() -> JSON {
        return JSON([])
    }
}
