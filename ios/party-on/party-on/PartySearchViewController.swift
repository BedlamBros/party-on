//
//  PartySearchViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SwiftyJSON

class PartySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView?
    @IBOutlet weak var useMapViewSwitch: UISwitch?
    
    var nearbyParties: Array<Party> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.table?.dataSource = self
        self.table?.delegate = self
        
        let myframe = self.view.frame

        if let t = table {
            let vertPercent: CGFloat = 0.9
            //t.frame = CGRectMake(0.0, myframe.height * (1.0 - vertPercent), myframe.width, myframe.height * vertPercent)
            println("\(myframe.width) \(t.frame.width)")
        }
        
        let indianaUniversity = University()
        
        let partyJsonArray = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("parties", ofType: "json")!)!)["parties"].arrayValue
        
        // initialize with dummy parties
        self.nearbyParties = Array(map(partyJsonArray, { (singlePartyJson: JSON) -> Party in
            Party(json: singlePartyJson)
        }))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "PartySearchCell"
        let cell: PartyTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! PartyTableViewCell
        
        let party = self.nearbyParties[indexPath.row]
        cell.nameLabel?.text = (party.colloquialName != nil) ? party.colloquialName : party.formattedAddress
        
        return cell
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nearbyParties.count
    }

}
