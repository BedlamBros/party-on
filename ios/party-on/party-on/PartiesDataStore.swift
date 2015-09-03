//
//  PartiesDataStore.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/3/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftyJSON
import Synchronized

typealias NearbyPartiesCallback = (err: NSError?, parties: [Party]?) -> Void

// WARNING: - Exposing all API secrets here
public let API_ROOT: String = "http://52.27.42.182/api"

class PartiesDataStore: NSObject {
   
    static var sharedInstance = PartiesDataStore()
    private let httpManager = AFHTTPRequestOperationManager()
    
    var nearbyParties: [Party] = []
    
    override init() {
        super.init()
        self.httpManager.requestSerializer.timeoutInterval = 2.5
    }
    
    func requeryNearbyParties(callback: NearbyPartiesCallback) {
        let syncCallback: NearbyPartiesCallback = { (err: NSError?, parties: [Party]?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                callback(err: err, parties: parties)
            })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var endpoint: String = "/parties/university/" + University.currentUniversity.name
            endpoint = endpoint.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            
            self.httpManager.GET(API_ROOT + endpoint, parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                // ON SUCCESS
                let json = JSON(response)
                if let partiesJsonArray = json["parties"].array {
                    // extract Parties from json
                    let parties: [Party] = map(partiesJsonArray, { (partyJson: JSON) -> Party in
                        return Party(json: partyJson)
                    })
                    // retain these parties as the current data store
                    synchronized(self.nearbyParties, { () -> Void in
                        self.nearbyParties = parties
                    })
                    // return success
                    return syncCallback(err: nil, parties: self.nearbyParties)
                } else {
                    // failed to extract "parties" array from json
                    let err = NSError(domain: "MMcLennan.party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not decode party json"])
                    return syncCallback(err: err, parties: nil)
                }
                }, failure: { (operation: AFHTTPRequestOperation!, err: NSError!) -> Void in
                    // ON ERROR
                    return syncCallback(err: err, parties: nil)
            })
        })
    }
}
