//
//  CreatePartyViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/3/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit

protocol CreatePartyViewControllerDelegate: class {
    func createPartyDidCancel(viewController : CreatePartyViewController)
}

class CreatePartyViewController: UIViewController {
    
    weak var delegate: CreatePartyViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonClick(sender: AnyObject?) {
        self.delegate?.createPartyDidCancel(self)
    }

    // MARK: - Networking
    
    func POST() {
        
    }

}
