//
//  PartyAnnotation.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/2/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import MapKit

class PartyAnnotation: MKPointAnnotation {
    
    var party: Party?
    
    override init() {
        super.init()
    }
    
    convenience init(party: Party) {
        self.init()
        self.party = party
    }
    
    override var title: String? {
        get {
            if super.title != nil {
                return super.title
            } else if let partyAddress = self.party?.formattedAddress {
                return partyAddress
            } else {
                return ""
            }
        } set {
            super.title = newValue
        }
    }
    
    override var subtitle: String? {
        get {
            if super.subtitle != nil {
                return super.subtitle
            } else if let colloquialName = self.party?.colloquialName {
                return colloquialName
            } else {
                return ""
            }
        } set {
            super.subtitle = newValue
        }
    }
    
    override var coordinate: CLLocationCoordinate2D {
        get {
            if let partyCoordinate = self.party?.location {
                return partyCoordinate
            } else {
                return super.coordinate
            }
        } set {
            super.coordinate = newValue
        }
    }
}
