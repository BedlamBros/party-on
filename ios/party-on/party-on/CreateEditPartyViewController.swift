//
//  CreateEditPartyViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/3/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import FBSDKLoginKit

enum CreateEditPartyActionType {
    case POST
    case PUT
    case DELETE
}

protocol CreateEditPartyViewControllerDelegate: class {
    func createEditPartyDidCancel(viewController: CreateEditPartyViewController)
    func createEditPartyDidSucceed(viewController: CreateEditPartyViewController, party: Party, method: CreateEditPartyActionType)
}

class CreateEditPartyViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: CreateEditPartyViewControllerDelegate?
    
    @IBOutlet weak var address: UITextField?
    @IBOutlet weak var guysPay: UITextField?
    @IBOutlet weak var girlsPay: UITextField?
    @IBOutlet weak var providedBool: UISegmentedControl?
    @IBOutlet weak var daySegmentedControl: UISegmentedControl?
    @IBOutlet weak var startTimePicker: UIDatePicker?
    @IBOutlet weak var startsLabel: UILabel?
    @IBOutlet weak var submitButton: UIButton?
    private weak var existingTimeLabel: UILabel?
    private weak var cancelUpdatingTimeButton: UIButton?
    private weak var startUpdatingTimeButton: UIButton?
    
    var method: CreateEditPartyActionType = .POST
    
    private var _timePickerIsHidden: Bool = false
    var timePickerIsHidden: Bool {
        get {
            return _timePickerIsHidden
        } set(hidden) {
            if self.method == .POST {
                // force showing of time picker during POST
                _timePickerIsHidden = false
            } else {
                _timePickerIsHidden = hidden
                
                self.startTimePicker?.hidden = hidden
                self.daySegmentedControl?.hidden = hidden
                self.cancelUpdatingTimeButton?.hidden = hidden
                self.startUpdatingTimeButton?.hidden = !hidden
                self.existingTimeLabel?.hidden = !hidden
            }
        }
    }
    
    private var _party: Party?
    var party: Party? {
        get {
            return _party
        } set(val) {
            if self.method == .POST || val == nil {
                // can't set a party for post
                _party = nil
            } else {
                _party = val
                
                self.address?.text = _party!.formattedAddress
                self.guysPay?.text = String(_party!.maleCost)
                self.girlsPay?.text = String(_party!.femaleCost)
                self.providedBool?.selectedSegmentIndex = _party!.byob ? 1 : 0
                
                // Put date into existing time label
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = self.dateFormatPattern
                self.existingTimeLabel?.text = dateFormatter.stringFromDate(_party!.startTime)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.address?.delegate = self
        self.guysPay?.delegate = self
        self.girlsPay?.delegate = self
        
        // Setup day switch to watch for day change
        self.daySegmentedControl?.addTarget(self, action: "didToggleDay", forControlEvents: .ValueChanged)
        self.daySegmentedControl?.selectedSegmentIndex = 0
        didToggleDay()
        
        // Font sizing for segmented controls
        let segmentedControlFont = UIFont.systemFontOfSize(11.0)
        self.daySegmentedControl?.setTitleTextAttributes([NSFontAttributeName: segmentedControlFont], forState: .Normal)
        self.providedBool?.setTitleTextAttributes([NSFontAttributeName: segmentedControlFont], forState: .Normal)
        
        let guysPayCurrencyLabel = UILabel(frame: CGRectMake(0, 0, 20, 50))
        guysPayCurrencyLabel.text = dollarSignPrefix
        self.guysPay?.leftView = guysPayCurrencyLabel
        self.guysPay?.leftViewMode = UITextFieldViewMode.Always
        
        let girlsPayCurrencyLabel = UILabel(frame: CGRectMake(0, 0, 20, 50))
        girlsPayCurrencyLabel.text = dollarSignPrefix
        self.girlsPay?.leftView = girlsPayCurrencyLabel
        self.girlsPay?.leftViewMode = UITextFieldViewMode.Always
        
        // Time picker
        self.startTimePicker?.minuteInterval = 15
        self.startTimePicker?.maximumDate = NSDate(timeIntervalSinceNow: Double.infinity)
        
        // Gesture recognizer to dismiss keyboard
        var dismissWhenTouchedViews: [UIView?] = [self.view]
        dismissWhenTouchedViews.append(self.startTimePicker)
        dismissWhenTouchedViews.append(self.providedBool)
        for view in dismissWhenTouchedViews {
            var dismissKeyboardRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
            dismissKeyboardRecognizer.cancelsTouchesInView = false
            view?.addGestureRecognizer(dismissKeyboardRecognizer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Create the hidden date change objects
        if self.existingTimeLabel == nil {
            let existingTimeLabel = UILabel(frame: self.daySegmentedControl!.frame)
            existingTimeLabel.font = UIFont(name: "Courier", size: 17.0)
            existingTimeLabel.hidden = self.method == .POST
            existingTimeLabel.textAlignment = .Left
            self.view.addSubview(existingTimeLabel)
            self.existingTimeLabel = existingTimeLabel
        }
        
        // rect of time toggle buttons
        
        let startsLabelRect = self.startsLabel!.frame
        let toggleTimeEditingFrame = CGRectMake(startsLabelRect.origin.x, startsLabelRect.origin.y + startsLabelRect.height + 10, startsLabelRect.width, startsLabelRect.height)
        
        let buttonFont = UIFont(name: "American Typewriter", size: 15.0)
        
        if self.cancelUpdatingTimeButton == nil {
            let cancelUpdatingTimeButton = UIButton.buttonWithType(.System) as! UIButton
            cancelUpdatingTimeButton.hidden = true
            cancelUpdatingTimeButton.setTitle("Keep original time", forState: .Normal)
            cancelUpdatingTimeButton.titleLabel?.font = buttonFont
            cancelUpdatingTimeButton.addTarget(self, action: "toggleEditingTime", forControlEvents: .TouchUpInside)
            cancelUpdatingTimeButton.setTitleColor(self.submitButton!.titleColorForState(.Normal), forState: .Normal)
            cancelUpdatingTimeButton.tintColor = self.submitButton!.tintColor
            cancelUpdatingTimeButton.frame = toggleTimeEditingFrame
            self.view.addSubview(cancelUpdatingTimeButton)
            self.cancelUpdatingTimeButton = cancelUpdatingTimeButton
        }
        
        if self.startUpdatingTimeButton == nil {
            let startUpdatingTimeButton = UIButton(frame: toggleTimeEditingFrame)
            startUpdatingTimeButton.hidden = self.method == .POST
            startUpdatingTimeButton.setTitle("Change Time", forState: .Normal)
            startUpdatingTimeButton.titleLabel?.font = buttonFont
            startUpdatingTimeButton.addTarget(self, action: "toggleEditingTime", forControlEvents: .TouchUpInside)
            startUpdatingTimeButton.setTitleColor(self.submitButton!.titleColorForState(.Normal), forState: .Normal)
            startUpdatingTimeButton.tintColor = self.submitButton!.tintColor
            startUpdatingTimeButton.frame = toggleTimeEditingFrame
            self.view.addSubview(startUpdatingTimeButton)
            self.startUpdatingTimeButton = startUpdatingTimeButton
        }
        
        if self.method == .PUT {
            dispatch_once(&initializeAsPUTHackOnceToken, { () -> Void in
                // @hack - reinforce some properties whose setters are important in PUT
                self.timePickerIsHidden = true
                let p = self.party
                self.party = p
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func backButtonClick(sender: AnyObject?) {
        self.delegate?.createEditPartyDidCancel(self)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField === self.guysPay || textField === self.girlsPay {
            if count(string) < 1 {
                return true
            }
            if string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet, options: NSStringCompareOptions.allZeros, range: nil) != nil {
                    return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


    // MARK: - Networking
    
    func submit() {
        var formattedAddress: String?
        var guysPay: Int?
        var girlsPay: Int?
        var byob: Bool?
        var startTime: NSDate?
        var userId: String?
        
        formattedAddress = self.address?.text
        guysPay = self.guysPay?.text.stringByReplacingOccurrencesOfString(dollarSignPrefix, withString: "", options: NSStringCompareOptions.allZeros, range: nil).toInt()
        girlsPay = self.girlsPay?.text.stringByReplacingOccurrencesOfString(dollarSignPrefix, withString: "", options: NSStringCompareOptions.allZeros, range: nil).toInt()
        
        if self.timePickerIsHidden && self.party != nil {
            // use the static time that party had previously
            startTime = self.party!.startTime
        } else {
            // use the time from the time picker
            let oneDay: NSTimeInterval = 60 * 60 * 24
            startTime = self.startTimePicker!.date
            if self.daySegmentedControl!.selectedSegmentIndex == 1 {
                // we're talking about tomorrow, so add a day
                startTime = NSDate(timeInterval: oneDay, sinceDate: startTime!)
            }
        }
        if let providedSelect = self.providedBool {
            byob = providedSelect.selectedSegmentIndex == 1
        }
        if let mainUser = MainUser.sharedInstance {
            userId = mainUser.oID
        }
        
        if formattedAddress == nil || guysPay == nil || girlsPay == nil || byob == nil || startTime == nil {
            // all fields must have a value
            return UIAlertView(title: "Oops", message: "Make sure to fill out all fields", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        let completionCallback = { (err: NSError?, party: Party?) -> Void in
            SVProgressHUD.dismissAndUnblockInteraction(self.view)
            if err == nil && party != nil {
                // success
                self.delegate?.createEditPartyDidSucceed(self, party: party!, method: self.method)
            } else {
                // failure
                var errMsg: String
                if let msg = err?.userInfo?[NSLocalizedDescriptionKey] as? String {
                    errMsg = msg
                } else {
                    errMsg = "Had trouble saving the party"
                }
                
                return UIAlertView(title: "Uh-oh", message: errMsg, delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }
        
        let sendPartyBlock = { () -> Void in
            let party = Party(oID: (self.party?.oID != nil ? self.party!.oID! : ""), formattedAddress: formattedAddress!, location: CLLocationCoordinate2DMake(0, 0), startTime: startTime!, endTime: nil, maleCost: NSNumber(integer: guysPay!).unsignedLongValue, femaleCost: NSNumber(integer: girlsPay!).unsignedLongValue, byob: byob!, colloquialName: nil, description: nil)
            SVProgressHUD.showAndBlockInteraction(self.view)
            
            switch self.method {
            case .POST:
                PartiesDataStore.sharedInstance.POST(party, callback: completionCallback)
            case .PUT:
                PartiesDataStore.sharedInstance.PUT(party, callback: completionCallback)
            default:
                break
            }
        }
        
        if userId == nil {
            // there was a problem logging in
            MainUser.loginWithFBToken({ (err) -> Void in
                // attempt to login because we know we're failing here
            })
            return completionCallback(NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't save party because user was not logged in"]), nil)
        } else if userId != MainUser.sharedInstance?.oID {
            return completionCallback(NSError(domain: "party-on", code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't update a party that doesn't belong to MainUser"]), nil)
        } else {
            sendPartyBlock()
        }
        
    }
    
    
    // MARK: - Generic selectors
    
    @IBAction func submitButtonClick() {
        submit()
    }
    
    func dismissKeyboard() {
        println("dismissKeyboard")
        println(self.startTimePicker!.date)
        self.view.endEditing(true)
    }
    
    func didToggleDay() {
        // Change allowed range of date picker based on day
        let calendar = NSCalendar.currentCalendar()
        let currentMinutes = calendar.component(.CalendarUnitMinute, fromDate: NSDate(timeIntervalSinceNow: 0))
        let minutesAwayFromPreviousFifteenInterval = currentMinutes % 15

        if self.daySegmentedControl!.selectedSegmentIndex == 0 {
            // Today
            let minDate = NSDate(timeIntervalSinceNow: NSTimeInterval(-60 * minutesAwayFromPreviousFifteenInterval))
            self.startTimePicker?.minimumDate = minDate
            self.startTimePicker?.setDate(minDate, animated: true)
        } else {
            // Tomorrow
            self.startTimePicker?.minimumDate = NSDate(timeIntervalSinceNow: -Double.infinity)
        }
    }
    
    func toggleEditingTime() {
        // Decided to stick with old date
        println("toggle editing")
        if self.method == .POST {
            fatalError("Should never be able to toggleEditingTime during POST")
        }
        self.timePickerIsHidden = !self.timePickerIsHidden
    }

    
    // MARK: - Primitive Constants
    
    private let dollarSignPrefix = " $"
    private let dateFormatPattern = "EEE h:mm a"
    private var initializeAsPUTHackOnceToken: dispatch_once_t = 0
}
