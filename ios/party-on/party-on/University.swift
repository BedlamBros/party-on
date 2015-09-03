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
    
    static var currentUniversity: University! = nil
    
    var oID: String!
    var name: String!
    var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init()
    }
    
    convenience init(name: String, location: CLLocationCoordinate2D) {
        self.init()
        self.name = name
        self.location = location
    }
    
}
