//
//  ServerModel.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ServerModel {
    var oID: String! { get set }
    init(json: JSON)
    func toJSON() -> JSON
}