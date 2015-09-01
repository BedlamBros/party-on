//
//  MainUser.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit

private let privateSharedInstance = MainUser()

class MainUser: User {
    
    class var sharedInstance: MainUser {
        return privateSharedInstance
    }
    
}
