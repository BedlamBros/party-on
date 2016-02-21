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
typealias UpdatePartyCallback = (err: NSError?, party: Party?) -> Void

// WARNING: - Exposing all API secrets here
public let API_ROOT: String = "http://52.10.210.220/api"

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
                    
                    let parties: [Party] = partiesJsonArray.map({ (partyJson: JSON) -> Party in
                        return Party(json: partyJson)
                    })
                    // retain these parties as the current data store
                    synchronized(self.nearbyParties, closure: { () -> Void in
                        self.nearbyParties = parties
                    })
                    // return success
                    return syncCallback(err: nil, parties: self.nearbyParties)
                } else {
                    // failed to extract "parties" array from json
                    let err = NSError(domain: "MMcLennan.party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not decode party json"])
                    return syncCallback(err: err, parties: nil)
                }
                }, failure: { (operation: AFHTTPRequestOperation?, err: NSError!) -> Void in
                    // ON ERROR
                    return syncCallback(err: err, parties: nil)
            })
        })
    }
    
    func getParty(oID: String, callback: UpdatePartyCallback) {
        let syncCallback: UpdatePartyCallback = { (err: NSError?, party: Party?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                callback(err: err, party: party)
            })
        }
        
        let endpoint = API_ROOT + "/parties/" + oID
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            self.httpManager.GET(endpoint, parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                let party = Party(json: JSON(response))
                self.updateSingleParty(party)
                return syncCallback(err: nil, party: party)
                }, failure: { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
                    return syncCallback(err: err, party: nil)
            })
        })
    }
    
    func flag(partyId: String, complaint: String?, callback: ((NSError?) -> Void)?) {
        let syncCallback = { (err: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                callback?(err)
            })
        }
        let endpoint = API_ROOT + "/parties/" + partyId + "/flag"
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var params = JSON([
                "party": partyId
            ])
            if let c = complaint {
                params["complaint"] = JSON(c)
            }
            
            self.httpManager.POST(endpoint, parameters: params.dictionaryObject, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                    return syncCallback(nil)
                }, failure: { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
                    return syncCallback(err)
            })
        })
    }
    
    func POST(party: Party, callback: UpdatePartyCallback) {
        return putOrPost(party, method: "POST", callback: callback)
    }
    
    func PUT(party: Party, callback: UpdatePartyCallback) {
        return putOrPost(party, method: "PUT", callback: callback)
    }
    
    func sendword(word: TheWordMessage, party: Party, callback: UpdatePartyCallback) {
        if let partyid = party.oID {
            let url = API_ROOT + "/parties/" + partyid + "/word"
            let params = word.toJSON().dictionaryObject
            
            let syncCallback: UpdatePartyCallback = { (err: NSError?, party: Party?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback(err: err, party: party)
                })
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.httpManager.PUT(url, parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                    let updatedParty = Party(json: JSON(response))
                    

                    if self.updateSingleParty(updatedParty) {
                        return syncCallback(err: nil, party: updatedParty)
                    } else {
                        return syncCallback(err: NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not send word for party not stored locally"]), party: nil)
                    }
                    }, failure: { (operation: AFHTTPRequestOperation?, err: NSError) -> Void in
                    return syncCallback(err: err, party: nil)
                })
            })
            
        } else {
            let err = NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot send word for blank Party oID"])
            return callback(err: err, party: nil)
        }
    }
    
    private func putOrPost(party: Party, method: String, callback: UpdatePartyCallback) {
        MainUser.applyAuthHeaders(self.httpManager)
        //self.httpManager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let syncCallback: UpdatePartyCallback = { (err: NSError?, party: Party?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                callback(err: err, party: party)
            })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var url = API_ROOT + "/parties"
            if method == "PUT" {
                // modify the route for PUT
                url += "/" + (party.oID != nil ? party.oID! : "")
            }
            var parameters = party.toJSON().dictionaryObject
            if parameters == nil {
                return syncCallback(err: NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create the party"]), party: nil)
            }
            
            let success: (AFHTTPRequestOperation, AnyObject) -> Void = { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                let json = JSON(response)
                if let badRequestError = Party.logicalErrorForJsonResponse(json) {
                    return syncCallback(err: badRequestError, party: nil)
                }
                let party = Party(json: JSON(response))
                
                // Synchronize changes in the party
                synchronized(self.nearbyParties, closure: { () -> Void in
                    switch method {
                    case "POST":
                        self.nearbyParties.insert(party, atIndex: 0)
                    case "PUT":
                        self.updateSingleParty(party)
                    default:
                        break
                    }
                })
                
                return syncCallback(err: nil, party: party)
            }
            let failure: (AFHTTPRequestOperation?, AnyObject) -> Void = { (operation: AFHTTPRequestOperation?, response: AnyObject) -> Void in
                let err = NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Server request failed"])
                return syncCallback(err: err, party: nil)
            }
            
            switch method {
            case "POST":
                parameters?.removeValueForKey("_id")
                self.httpManager.POST(url, parameters: parameters!, success: success, failure: failure)
            case "PUT":
                self.httpManager.PUT(url, parameters: parameters!, success: success, failure: failure)
            default:
                return syncCallback(err: NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not a valid http method"]), party: nil)
            }
        })
    }
    
    private func updateSingleParty(updatedParty: Party) -> Bool {
        // update the party within the PartiesDataStore
        return synchronized(self.nearbyParties, closure: { () -> Bool in
            for (idx, party) in self.nearbyParties.enumerate() {
                if party.oID != nil && party.oID == updatedParty.oID {
                    // found the old party, update it
                    print("PartiesDataStore is replacing party \(updatedParty.oID)")
                    self.nearbyParties[idx] = updatedParty
                    return true
                }
            }
            // couldn't find the old party in .nearbyParties
            return false
        })
    }
}
