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
import SVProgressHUD

public let OK_EMOJI: Character = "\u{1F44C}"
public let THUMBS_DOWN_EMOJI: Character = "\u{1F44E}"

// Receives a signal when one particular party changed
protocol SinglePartyDidChangeResponder: class {
    func singlePartyDidChange(party: Party)
}

class PartyDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, CreateEditPartyViewControllerDelegate {
    
    @IBOutlet weak var addressButton: UIButton?
    @IBOutlet weak var textFriendButton: UIButton?
    @IBOutlet weak var providedBoolLabel: UILabel?
    @IBOutlet weak var guysPayLabel: UILabel?
    @IBOutlet weak var girlsPayLabel: UILabel?
    @IBOutlet weak var startsLabel: UILabel?
    @IBOutlet weak var theWordTableView: UITableView?
    @IBOutlet weak var dayLabel: UILabel?
    
    // Optional Fields
    @IBOutlet weak var endsLabel: UILabel?
    @IBOutlet weak var endsLabelLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var descriptionTextView: UITextView?
    
    weak var singlePartyDidChangeResponder: SinglePartyDidChangeResponder?
    
    // keep track of alert controllers
    private weak var flagMessageAlertController: UIAlertController?
    private weak var theWordMessageAlertController: UIAlertController?
    
    var _party: Party!
    var party: Party! {
        get {
            return _party
        } set {
            var shouldUpdateTheWord = true
            if newValue != nil && _party != nil {
                shouldUpdateTheWord = newValue.theWord.count != _party.theWord.count
            }
            
            _party = newValue
            
            // Fill in Party data
            self.navigationItem.title = _party.formattedAddress
            self.providedBoolLabel?.text = _party.byob ? "BYO" : "PROVIDED"
            self.party.maleCost == 0;
            self.guysPayLabel?.text = _party.maleCost != 0 ? "$" + String(_party.maleCost) : "FREE"
            self.girlsPayLabel?.text = _party.femaleCost != 0 ? "$" + String(_party.femaleCost) : "FREE"
            self.dayLabel?.text = _party.startDay
            
            
            let timeFormatter = NSDateFormatter()
            timeFormatter.timeZone = NSTimeZone.systemTimeZone()
            timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            self.startsLabel?.text = timeFormatter.stringFromDate(_party.startTime)

            if shouldUpdateTheWord {
                self.theWordTableView?.reloadData()
                self.scrollToTheWordBottom(true)
            }
        }
    }
    
    private var refreshPartyTimer: NSTimer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.theWordTableView?.dataSource = self
        self.theWordTableView?.delegate = self
        scrollToTheWordBottom(false)
        
        scheduleRefreshParty()
        
        // Navigation Item Title
        self.navigationItem.title = party.formattedAddress
        
        var navigationBarTextAttrs: [String: AnyObject] = [:]
        if let smallCourier = UIFont(name: "AmericanTypewriter", size: 15) {
            navigationBarTextAttrs[NSFontAttributeName] = smallCourier
        }
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTextAttrs
        
        // Determine which right bar button item to use
        print("PartyDetailViewController comparing storied id \(MainUser.storedUserId) to party's id \(self.party.userId)")
        if MainUser.storedUserId != nil && MainUser.storedUserId == self.party.userId {
            // MainUser made this party
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editPartyButtonClick")
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(navigationBarTextAttrs, forState: .Normal)
        } else {
            // This is someone else's party, flag
            let flagImage = UIImage(named: "grayed_white_flag_icon.png")
            let flagImageView = UIImageView(frame: CGRectMake(8, 8, 36, 36))
            flagImageView.image = flagImage
            flagImageView.contentMode = UIViewContentMode.ScaleAspectFit
            flagImageView.alpha = 0.8
            flagImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "flagTapped"))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flagImageView)
        }
        
        let now = NSDate(timeIntervalSinceNow: 0)
        if now.timeIntervalSince1970 < party.startTime.timeIntervalSince1970 {
            // party is in the future
        } else {
            // party is in the past
        }
        
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
        
        // force triggering of party population
        self.party = _party
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.partyDetailControllerInFocus = self
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.descheduleRefreshParty()
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.partyDetailControllerInFocus = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == editPartySegueIdentifier {
            let editPartyController = segue.destinationViewController as! CreateEditPartyViewController
            self.descheduleRefreshParty()
            editPartyController.delegate = self
            editPartyController.method = .PUT
            editPartyController.party = self.party
        }
    }
    
    
    // Mark: - Flagging
    
    func flagTapped() {
        let flagDialog = UIAlertController(title: "Report Abuse", message: "If this posting got out of hand, or if the party got kind of scary, leave us a message and we'll take a look at it", preferredStyle: UIAlertControllerStyle.Alert)
        self.flagMessageAlertController = flagDialog
        
        flagDialog.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.autocapitalizationType = .Sentences
            textField.addTarget(self, action: "alertTextFieldDidChange:", forControlEvents: .EditingChanged)
        }
        
        flagDialog.addAction(UIAlertAction(title: "Report", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction) -> Void in
            self.sendFlagRequest(flagDialog.textFields?.first?.text)
            flagDialog.dismissViewControllerAnimated(true, completion: nil)
        }))
        // make the report action disabled until text appears in the textField
        flagDialog.actions[0].enabled = false
        
        flagDialog.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
            flagDialog.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(flagDialog, animated: true, completion: nil)
    }
    
    private func sendFlagRequest(complaint: String?) {
        let displayErrorDialog = { () -> Void in
            UIAlertView(title: "Oh no", message: "Failed to flag this party. Try again another time.", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        if self.party.oID == nil {
            // doon't seg fault for lack of oID, it's not worth the risk
            return displayErrorDialog()
        }
        
        SVProgressHUD.showAndBlockInteraction(self.view)
        PartiesDataStore.sharedInstance.flag(self.party.oID!, complaint: complaint) { (err: NSError?) -> Void in
            SVProgressHUD.dismissAndUnblockInteraction(self.view)
            
            if err == nil {
                UIAlertView(title: "Thanks for keeping watch", message: "We'll take a look at this party and remove it if need be", delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                displayErrorDialog()
            }
        }
    }
    
    
    // MARK: - MFMessageComposeViewControllerDelegate methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            if result.rawValue == MessageComposeResultFailed.rawValue {
                UIAlertView(title: "Oh no!", message: "Message failed to send", delegate: nil, cancelButtonTitle: "Ok").show()
            }
            // presenting this controller stopped refreshing the party, restart
            self.scheduleRefreshParty()
        })
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
        if MFMessageComposeViewController.canSendText() {
            let textController = MFMessageComposeViewController()
            textController.messageComposeDelegate = self
            textController.body = self.party.formattedAddress
            self.presentViewController(textController, animated: true, completion: nil)
        } else {
            UIAlertView(title: "Can't send message", message: "Looks like your phone isn't configured to send text messages", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    func alertTextFieldDidChange(sender: UITextField!) {
        // decide if alert controller's buttons should be enabled or disabled
        // based on the values of their text fields
        
        if let textField = self.flagMessageAlertController?.textFields?.first {
            // textField belongs to flagMessageAlertController
            if sender === textField {
                self.flagMessageAlertController!.actions[0].enabled =
                    sender.text != nil && sender.text!.characters.count > 0
            }
        }
        
        if let textField = self.theWordMessageAlertController?.textFields?.first {
            // textField belongs to theWordMessageAlertController
            if sender === textField {
                self.theWordMessageAlertController!.actions[1].enabled =
                    sender.text != nil &&
                    sender.text!.characters.count > 0 &&
                    sender.text!.characters.count <= TheWordMessage.maxAllowedMessageLength
            }
        }
    }
    
    func sendTheWordMessage(wordText: String?) {
        let displayErrorDialog = { () -> Void in
            UIAlertView(title: "Oh no", message: "Failed to send message. Try again another time.", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        if wordText != nil && wordText!.characters.count > 0 {
            let newWord = TheWordMessage(oID: nil, body: wordText!, created: NSDate(timeIntervalSinceNow: 0))
            SVProgressHUD.showAndBlockInteraction(self.view)
            PartiesDataStore.sharedInstance.sendword(newWord, party: self.party, callback: { (err, party) -> Void in
                SVProgressHUD.dismissAndUnblockInteraction(self.view)
                
                if err == nil {
                    // reload TheWord locally
                    self.party = party
                    print("\(self.party!.theWord.count) msgs in party word")
                } else {
                    displayErrorDialog()
                }
            })
        } else {
            displayErrorDialog()
        }
    }
    
    /* schedule a timer to periodically refresh the party */
    func scheduleRefreshParty() {
        if self.refreshPartyTimer == nil {
            print("scheduling refresh party")
            self.refreshPartyTimer = NSTimer.scheduledTimerWithTimeInterval(refreshPartyTimeInterval, target: self, selector: "refreshParty", userInfo: nil, repeats: true)
            self.refreshPartyTimer?.fire()
        }
    }
    
    /* kill the timer that is refreshing the party */
    func descheduleRefreshParty() {
        print("descheduling refresh party")
        self.refreshPartyTimer?.invalidate()
        self.refreshPartyTimer = nil
    }
    
    /* Refresh the data for this party and its entry in the PartiesDataStore */
    func refreshParty() {
        print("refresh party")
        if let myPartyId = self.party.oID {
            PartiesDataStore.sharedInstance.getParty(myPartyId, callback: { (err, party) -> Void in
                if err == nil {
                    self.party = party
                }
            })
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.party.theWord.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if let message = theWordForRowAtIndexPath(indexPath, tableView: tableView) {
            let wordCell: TheWordTableViewCell = tableView.dequeueReusableCellWithIdentifier(theWordReadCellReuseIdentifier, forIndexPath: indexPath) as! TheWordTableViewCell
            wordCell.bodyLabel?.text = message.body
            
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            wordCell.dateLabel?.text = timeFormatter.stringFromDate(self.party.theWord[indexPath.row].created)
            
            cell = wordCell
        } else {
            // last row in the table
            cell = tableView.dequeueReusableCellWithIdentifier(theWordWriteCellReuseIdentifier, forIndexPath: indexPath) 
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var text: String
        if let message = theWordForRowAtIndexPath(indexPath, tableView: tableView) {
            text = message.body
        } else {
            // last row in table
            return minTheWordCellHeight
        }
        
        let width = tableView.frame.width
        
        var font = UIFont.systemFontOfSize(16)
        if let courierFont = UIFont(name: "AmericanTypewriter", size: 15) {
            font = courierFont
        }
        
        let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        
        let bodySize = attributedString.size()
        let linesOfText = ceil(bodySize.width / width) + 1
        let requiredBodyDrawHeight = max(bodySize.height, minTheWordBodyLabelHeight) * linesOfText

        let timeLabelHeight = constTheWordDateLabelHeight
        return max(ceil(requiredBodyDrawHeight) + timeLabelHeight, minTheWordCellHeight)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if theWordForRowAtIndexPath(indexPath, tableView: tableView) == nil {
            // Dealing with the create comment cell
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            launchSendMessageDialog()
        }
    }
    
    
    // MARK: CreateEditPartyViewControllerDelegate
    
    func createEditPartyDidCancel(viewController: CreateEditPartyViewController) {
        viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.scheduleRefreshParty()
        })
    }
    
    func createEditPartyDidSucceed(viewController: CreateEditPartyViewController, party: Party, method: CreateEditPartyActionType) {
        self.party = party
        viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.scheduleRefreshParty()
            self.singlePartyDidChangeResponder?.singlePartyDidChange(party)
        })
    }
    
    
    // MARK: Helpers
    
    private func theWordForRowAtIndexPath(indexPath: NSIndexPath, tableView: UITableView) -> TheWordMessage? {
        if indexPath.row == tableView.dataSource!.tableView(tableView, numberOfRowsInSection: indexPath.row) - 1 {
            // last row in table
            return nil
        } else {
            return self.party.theWord[indexPath.row]
        }
    }
    
    private func launchSendMessageDialog() {
        let sendTheWordAlertController = UIAlertController(title: "Spread the word", message: "What's going on at this party?", preferredStyle: .Alert)
        self.theWordMessageAlertController = sendTheWordAlertController
        
        sendTheWordAlertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.autocapitalizationType = .Sentences
            textField.addTarget(self, action: "alertTextFieldDidChange:", forControlEvents: .EditingChanged)
        }
        
        sendTheWordAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
            sendTheWordAlertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        sendTheWordAlertController.addAction(UIAlertAction(title: "Send", style: .Default, handler: { (action: UIAlertAction) -> Void in
            self.sendTheWordMessage(sendTheWordAlertController.textFields?.first?.text)
            sendTheWordAlertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        // make the send action disabled until text appears in the textField
        sendTheWordAlertController.actions[1].enabled = false
        
        self.presentViewController(sendTheWordAlertController, animated: true, completion: nil)
    }
    
    private func scrollToTheWordBottom(animated: Bool) {
        if let theWordTableView = self.theWordTableView {
            let bottomSection = theWordTableView.numberOfSections - 1
            let bottomCell = theWordTableView.numberOfRowsInSection(bottomSection) - 1
            theWordTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: bottomCell, inSection: bottomSection), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
    
    func editPartyButtonClick() {
        self.performSegueWithIdentifier(editPartySegueIdentifier, sender: self)
    }
    
    
    // MARK: Primitive Constants
    
    private let theWordReadCellReuseIdentifier = "TheWordReadCell"
    private let theWordWriteCellReuseIdentifier = "TheWordWriteCell"
    private let editPartySegueIdentifier = "EditPartySegue"
    private let minTheWordCellHeight: CGFloat = 44
    private let constTheWordDateLabelHeight: CGFloat = 12
    private let minTheWordBodyLabelHeight: CGFloat = 21
    private let refreshPartyTimeInterval: NSTimeInterval = 10
}



