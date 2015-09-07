//
//  Party.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

class Party: NSObject, ServerModel {
    var oID: String!// required
    var formattedAddress: String!// required
    var location: CLLocationCoordinate2D!// required
    var maleCost: UInt = 0// required - default 0
    var femaleCost: UInt = 0// required - default 0
    var startTime: NSDate!// required
    var byob: Bool = true// required default true
    
    var colloquialName: String?// optional
    var descrip: String?// optional - 256 char max
    
    var endTime: NSDate?
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        // required properties
        self.oID = json["_id"].stringValue
        self.formattedAddress = json["formattedAddress"].stringValue
        
        let latitude = CLLocationDegrees(json["latitude"].number!.doubleValue)
        let longitude = CLLocationDegrees(json["longitude"].number!.doubleValue)
        self.location = CLLocationCoordinate2DMake(latitude, longitude)
        
        self.maleCost = json["maleCost"].number!.unsignedLongValue
        self.femaleCost = json["femaleCost"].number!.unsignedLongValue
        self.byob = json["byob"].boolValue
        
        self.startTime = NSDate(timeIntervalSince1970: json["startTime"].number!.doubleValue / 1000)
        
        // optional properties
        if let colloquialName = json["colloquialName"].string {
            self.colloquialName = colloquialName
        }
        if let description = json["description"].string {
            self.descrip = description
        }
        
        super.init()
        
        if let endTime = json["endTime"].number {
            self.endTime = NSDate(timeIntervalSince1970: json["endTime"].number!.doubleValue / 1000)
        }
    }
    
    convenience init(oID: String, formattedAddress: String, location: CLLocationCoordinate2D, startTime: NSDate, endTime: NSDate?, maleCost: UInt, femaleCost: UInt, byob: Bool, colloquialName: String?, description: String?) {
        self.init()
        self.oID = oID
        self.formattedAddress = formattedAddress
        self.location = location
        self.startTime = startTime
        self.maleCost = maleCost
        self.femaleCost = femaleCost
        self.byob = byob
        self.colloquialName = colloquialName
        self.descrip = description
        self.endTime = endTime
        
    }
}
