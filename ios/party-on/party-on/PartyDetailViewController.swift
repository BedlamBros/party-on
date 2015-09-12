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

class PartyDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var addressButton: UIButton?
    @IBOutlet weak var textFriendButton: UIButton?
    @IBOutlet weak var providedBoolLabel: UILabel?
    @IBOutlet weak var guysPayLabel: UILabel?
    @IBOutlet weak var girlsPayLabel: UILabel?
    @IBOutlet weak var startsLabel: UILabel?
    @IBOutlet weak var theWordTableView: UITableView?
    
    // Optional Fields
    @IBOutlet weak var endsLabel: UILabel?
    @IBOutlet weak var endsLabelLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var descriptionTextView: UITextView?
    
    private static var textMessageViewController: MFMessageComposeViewController?
    
    var party: Party!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.theWordTableView?.dataSource = self
        self.theWordTableView?.delegate = self
        
        // Navigation Item
        self.navigationItem.title = party.formattedAddress
        
        var navigationBarTextAttrs: [NSObject: AnyObject] = [:]
        if let smallCourier = UIFont(name: "AmericanTypewriter", size: 15) {
            navigationBarTextAttrs[NSFontAttributeName] = smallCourier
        }
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTextAttrs
        

        
        // Init texting controller
        if MFMessageComposeViewController.canSendText() {
            PartyDetailViewController.textMessageViewController = MFMessageComposeViewController()
        }
        
        // Fill in Party data
        self.providedBoolLabel?.text = party.byob ? "BYO" : "PROVIDED"
        self.party.maleCost == 0;
        self.guysPayLabel?.text = self.party.maleCost != 0 ? "$" + String(self.party.maleCost) : "FREE"
        self.girlsPayLabel?.text = self.party.femaleCost != 0 ? "$" + String(self.party.femaleCost) : "FREE"
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeZone = NSTimeZone.systemTimeZone()
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.startsLabel?.text = timeFormatter.stringFromDate(self.party.startTime)
        
        //if let endTime = self.party.endTime {
        if false {
            //self.endsLabel?.text = timeFormatter.stringFromDate(endTime)
        } else {
            self.endsLabel?.hidden = true
            self.endsLabelLabel?.hidden = true
        }
        
        //if let description = self.party.descrip {
        if false {
            //self.descriptionTextView?.text = description
        } else {
            self.descriptionTextView?.hidden = true
            self.descriptionLabel?.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
    // MARK: - UIAlertViewDelegate methods
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            // Send button
            println("sending message")
        } else {
            // Cancel button
            alertView.dismissWithClickedButtonIndex(buttonIndex, animated: true)
        }
    }
    
    func alertViewCancel(alertView: UIAlertView) {
        // WARN: - Because of the way I hacked this AlertView, it won't call alertViewCancel correctly. Don't use it.
    }
    
    
    // MARK: - Generic Selectors
    
    @IBAction func addressButtonClick(sender: AnyObject?) {
        let latLongString = String(format: "http://maps.apple.com/?q=%f,%f", self.party.location.latitude, self.party.location.longitude)
        UIApplication.sharedApplication().openURL(NSURL(string: latLongString)!)
        
        /* Use this if you want to open a MapView within the app instead of in Maps
        
        let mapViewController = ModalMapViewController()
        let partyPoint = PartyAnnotation(party: self.party!)
        mapViewController.annotations = [partyPoint]
        self.presentViewController(mapViewController, animated: true, completion: nil)*/
        
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
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyMessages.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if let message = commentForRowAtIndexPath(indexPath, tableView: tableView) {
            cell = tableView.dequeueReusableCellWithIdentifier(theWordReadCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = message

        } else {
            // last row in the table
            cell = tableView.dequeueReusableCellWithIdentifier(theWordWriteCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var text: String
        if let message = commentForRowAtIndexPath(indexPath, tableView: tableView) {
            text = message
        } else {
            // last row in table
            text = ""
        }
        
        let width = tableView.frame.width
        let font = UIFont.systemFontOfSize(16)
        
        let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let boundingRect = attributedString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)

        return max(boundingRect.height, minTheWordCellHeight)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if commentForRowAtIndexPath(indexPath, tableView: tableView) == nil {
            // Dealing with the create comment cell
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            launchSendMessageDialog()
        }
    }
    
    
    // MARK: Helpers
    
    func commentForRowAtIndexPath(indexPath: NSIndexPath, tableView: UITableView) -> String? {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: indexPath.row) - 1 {
            // last row in table
            return nil
        } else {
            return dummyMessages[indexPath.row]
        }
    }
    
    func launchSendMessageDialog() {
        // launch an alert view for sending a message
        let dialog = UIAlertView(title: "Spread the word", message: "What's going on at this party?", delegate: self, cancelButtonTitle: "Send", otherButtonTitles: "Nevermind")
        dialog.alertViewStyle = UIAlertViewStyle.PlainTextInput
        dialog.show()
    }
    
    
    // MARK: Primitive Constants
    
    private let theWordReadCellReuseIdentifier = "TheWordReadCell"
    private let theWordWriteCellReuseIdentifier = "TheWordWriteCell"
    private let minTheWordCellHeight: CGFloat = 44
    
    private let dummyMessages = [
        "Nothing yet",
        "Heating up",
        "They ran out of alcohol alksfjsad nweorinqw inweroqwnr oiwenriowrn niowernqower oiwenroqew",
        "Great keg just got here"
    ]
}

