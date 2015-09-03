//
//  PartyDetailViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit

class PartyDetailViewController: UIViewController {
    
    var party: Party!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = party.formattedAddress
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
