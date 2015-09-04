//
//  PartyDetailViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

public let OK_EMOJI: Character = "\u{1F44C}"
public let THUMBS_DOWN_EMOJI: Character = "\u{1F44E}"

class PartyDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var addressButton: UIButton?
    @IBOutlet weak var textFriendButton: UIButton?
    @IBOutlet weak var providedBoolLabel: UILabel?
    @IBOutlet weak var guysPayTextField: UITextField?
    @IBOutlet weak var girlsPayTextFiled: UITextField?
    
    private static var textMessageViewController: MFMessageComposeViewController?
    
    var party: Party!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = party.formattedAddress
        
        if MFMessageComposeViewController.canSendText() {
            PartyDetailViewController.textMessageViewController = MFMessageComposeViewController()
        }
        
        self.providedBoolLabel?.text = party.byob ? String(THUMBS_DOWN_EMOJI) : String(OK_EMOJI)
        self.party.maleCost == 0;
        self.guysPayTextField?.text = self.party.maleCost == 0 ? String(self.party.maleCost) : "Nothing!"
        self.girlsPayTextFiled?.text = self.party.femaleCost != 0 ? String(self.party.femaleCost) : "Nothing!"
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
    
    
    // MARK: - MFMessageComposeViewControllerDelegate methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            if result.value == MessageComposeResultFailed.value {
                UIAlertView(title: "Oh no!", message: "Message failed to send", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        })
    }
    
    
    // MARK: - Generic Selectors
    
    @IBAction func addressButtonClick(sender: AnyObject?) {
        let mapViewController = ModalMapViewController()
        let partyPoint = PartyAnnotation(party: self.party!)
        mapViewController.annotations = [partyPoint]
        self.presentViewController(mapViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func sendTextMessageButtonClick(sender: AnyObject?) {
        if let textController = PartyDetailViewController.textMessageViewController {
            textController.messageComposeDelegate = self
            textController.body = self.party.formattedAddress
            self.presentViewController(textController, animated: true, completion: nil)
        } else {
            UIAlertView(title: "Can't send message", message: "Looks like your phone isn't configured to send text messages", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
}


