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

enum UniversityType : String {
    case IndianaUniversity = "Indiana University"
}

class University: NSObject, ServerModel {
    
    private static var privateCurrentUniversity: University!
    static var currentUniversity: University! {
        get {
            return privateCurrentUniversity
        } set(val) {
            // Remember the user's university preference
            let preferences = NSUserDefaults.standardUserDefaults()
            preferences.setObject(val.name, forKey: universityPreferencesKey)
            preferences.synchronize()
            
            privateCurrentUniversity = val
        }
    }
    private static var universitiesDB = [UniversityType.IndianaUniversity: University(name: UniversityType.IndianaUniversity.rawValue, location: CLLocationCoordinate2D(latitude: 39.1691355, longitude: -86.5149053))]
    
    
    
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
    
    class func universityForType(type: UniversityType) -> University {
        return self.universitiesDB[type]!
    }
    
    // returns the user's preferred university if one exists
    class func getStoredUniversityPreference() -> University? {
        var retVal: University?
        var x = NSUserDefaults.standardUserDefaults().stringForKey(universityPreferencesKey)
        if let storedUniversityString = NSUserDefaults.standardUserDefaults().stringForKey(universityPreferencesKey) {
            if let storedUniversityType = UniversityType(rawValue: storedUniversityString) {
                if let university = universitiesDB[storedUniversityType] {
                    retVal = university
                }
            }
        }
        return retVal
    }
    
    private static let universityPreferencesKey = "CurrentUniversity"
}
