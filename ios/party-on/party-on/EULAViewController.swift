//
//  EULAViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/14/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {
    
    @IBOutlet weak var eulaTextView: UITextView?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let eulaText = try? String(contentsOfFile: NSBundle.mainBundle().pathForResource("EULA", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        self.eulaTextView!.text = eulaText!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didAcceptEULA() {
        // save the acceptance to userDefaults
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: AppDelegate.didAcceptEULADefaultsKey)
        userDefaults.synchronize()
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            // now check for banned status
            appDelegate.checkForBanned()
        }
    }

}
