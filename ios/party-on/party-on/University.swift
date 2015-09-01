//
//  University.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class University: NSObject, ServerModel {
    
    var oID: String!
    var name: String?
    var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init()
    }
    
}
