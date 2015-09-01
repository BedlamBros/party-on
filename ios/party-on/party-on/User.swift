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
    
    var oID: String!
    var username: String?
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init()
    }
}
