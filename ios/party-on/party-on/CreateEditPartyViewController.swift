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
    @IBOutlet weak var startTimePicker: UIDatePicker?
    
    var method: CreateEditPartyActionType = .POST

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.address?.delegate = self
        self.guysPay?.delegate = self
        self.girlsPay?.delegate = self
        
        let guysPayCurrencyLabel = UILabel(frame: CGRectMake(0, 0, 20, 50))
        guysPayCurrencyLabel.text = dollarSignPrefix
        self.guysPay?.leftView = guysPayCurrencyLabel
        self.guysPay?.leftViewMode = UITextFieldViewMode.Always
        
        let girlsPayCurrencyLabel = UILabel(frame: CGRectMake(0, 0, 20, 50))
        girlsPayCurrencyLabel.text = dollarSignPrefix
        self.girlsPay?.leftView = girlsPayCurrencyLabel
        self.girlsPay?.leftViewMode = UITextFieldViewMode.Always
        
        // Gesture recognizer to dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
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
        startTime = self.startTimePicker?.date
        if let providedSelect = self.providedBool {
            byob = providedSelect.selectedSegmentIndex == 1
        }
        if let mainUser = MainUser.sharedInstance {
            userId = mainUser.oID
        }
        
        if formattedAddress == nil || guysPay == nil || girlsPay == nil || byob == nil || startTime == nil || userId == nil {
            // all fields must have a value
            return UIAlertView(title: "Oops", message: "Make sure to fill out all fields", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        let party = Party(oID: "", formattedAddress: formattedAddress!, location: CLLocationCoordinate2DMake(0, 0), startTime: startTime!, endTime: nil, maleCost: NSNumber(integer: guysPay!).unsignedLongValue, femaleCost: NSNumber(integer: girlsPay!).unsignedLongValue, byob: byob!, colloquialName: nil, description: nil)
        
        SVProgressHUD.showAndBlockInteraction(self.view)
        PartiesDataStore.sharedInstance.POST(party, callback: { (err, party) -> Void in
            SVProgressHUD.dismissAndUnblockInteraction(self.view)
            if err == nil && party != nil {
                // success
                self.delegate?.createEditPartyDidSucceed(self, party: party!, method: self.method)
            } else {
                // failure
                return UIAlertView(title: "Uh-oh", message: "Had trouble saving the party", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        })
    }
    
    
    // MARK: - Generic selectors
    
    @IBAction func submitButtonClick() {
        submit()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    
    // MARK: - Primitive Constants
    
    private let dollarSignPrefix = " $"
}
