//
//  CurrentUniversity.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import CoreLocation
import SwiftyJSON

private let privateSharedInstance = CurrentUniversity()

class CurrentUniversity: University {
   
    class var sharedInstance: CurrentUniversity {
        return privateSharedInstance
    }
    
    private func setup() {
        // Hard code IU as the CurrentUniversity
        self.name = "Indiana University"
        self.location = CLLocationCoordinate2D(latitude: 39.1691355, longitude: -86.5149053)
    }
    
    
    override init() {
        super.init()
        setup()
    }

    required init(json: JSON) {
        super.init(json: json)
    }
    
}
