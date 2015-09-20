//
//  PartySearchViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit

public let SADFACE_CHAR: Character = "\u{1F61E}"

class PartySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, FBSDKLoginButtonDelegate, CreateEditPartyViewControllerDelegate {
    
    @IBOutlet var listView: UITableView?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var useMapViewSegmentedControl: UISegmentedControl?
    weak var refreshControl: UIRefreshControl!
    private var fbLoginButton: FBSDKLoginButton!
    
    private weak var selectedParty: Party?

    private var requeryLock: NSLock = NSLock()
    private var navigationBarButtonTextAttributes: [NSObject: AnyObject]!
    
    // handle on the create party bar button
    private weak var createPartyPressGestureRecognizer: UILongPressGestureRecognizer?
    private weak var createPartyBarButtonImageView: UIImageView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listView?.dataSource = self
        self.listView?.delegate = self
        
        let myframe = self.view.frame
        
        self.mapView?.delegate = self
        
        let tableRefreshControl = UIRefreshControl()
        tableRefreshControl.layer.zPosition -= 1
        
        // Facebook Login Button
        self.fbLoginButton = FBSDKLoginButton()
        fbLoginButton.readPermissions = ["public_profile"]
        fbLoginButton.delegate = self
        
        
        let refereshImageView = UIImageView(image: UIImage(named: "culture-newspaper-illegal.jpg"))
        
        // Refresh Control
        tableRefreshControl.insertSubview(refereshImageView, atIndex: 0)
        tableRefreshControl.addSubview(refereshImageView)
        
        tableRefreshControl.addTarget(self, action: "requery", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = tableRefreshControl
        //self.listView?.backgroundView = refereshImageView
        //self.listView?.backgroundColor = UIColor.whiteColor()
        //self.listView?.addSubview(refereshImageView)
        self.listView?.addSubview(tableRefreshControl)
        
        let partyJsonArray = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("parties", ofType: "json")!)!)["parties"].arrayValue
        
        // Modify navigatonBar appearance
        var navigationBarTextAttrs: [NSObject: AnyObject] = [:]
        if let largeCourier = UIFont(name: "Courier", size: 22) {
            navigationBarTextAttrs[NSFontAttributeName] = largeCourier
        }
        self.navigationController?.navigationBar.titleTextAttributes = navigationBarTextAttrs
        
        var barButtonTextAttrs: [NSObject: AnyObject] = [:]
        if let smallCourier = UIFont(name: "Courier", size: 12) {
            barButtonTextAttrs[NSFontAttributeName] = smallCourier
        }
        // save these options for all other navigation buttons
        self.navigationBarButtonTextAttributes = barButtonTextAttrs
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(barButtonTextAttrs, forState: UIControlState.Normal)
        
        // Add Party Bar Button Item
        let partyHatImage = UIImage(named: "ic_add_party2.png")!
        // TODO: get a party hat image with better density
        let partyHatImageView = UIImageView(frame: CGRectMake(4, 4, 40, 40))
        partyHatImageView.contentMode = .ScaleAspectFit
        partyHatImageView.image = partyHatImage
        
        let createPartyRecognizer = UILongPressGestureRecognizer(target: self, action: "createPartyButtonClick:")
        createPartyRecognizer.minimumPressDuration = 0.0
        partyHatImageView.addGestureRecognizer(createPartyRecognizer)
        
        self.createPartyPressGestureRecognizer = createPartyRecognizer
        self.createPartyBarButtonImageView = partyHatImageView
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: partyHatImageView)
        
        // Start off with a requery of parties
        requery()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let listView = self.listView {
            if let selectedIndexPath = listView.indexPathForSelectedRow() {
                listView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == partyDetailSegueIdentifier {
            let partyDetailViewController = segue.destinationViewController as! PartyDetailViewController
            partyDetailViewController.party = self.selectedParty
            
            // Set up the NEXT viewController's backItem, which is a property of self here
            let backItem = UIBarButtonItem(title: nil, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            backItem.setTitleTextAttributes(navigationBarButtonTextAttributes, forState: UIControlState.Normal)
            self.navigationItem.backBarButtonItem = backItem
            
        } else if segue.identifier == createPartySegueIdentifier {
            let createPartyController = segue.destinationViewController as! CreateEditPartyViewController
            createPartyController.delegate = self
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let isFillerCell = indexPath.row >= PartiesDataStore.sharedInstance.nearbyParties.count
        let reuseIdentifier =  isFillerCell ?  fillerCellReuseIdentifier : partyCellReuseIdentifier
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        if !isFillerCell {
            // is a party cell
            if let partyCell = cell as? PartyTableViewCell {
                let party = PartiesDataStore.sharedInstance.nearbyParties[indexPath.row]
                partyCell.nameLabel?.text = party.colloquialName != nil ? party.colloquialName : party.formattedAddress
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let parties = PartiesDataStore.sharedInstance.nearbyParties
        if indexPath.row < parties.count {
            // selecting a party from the tableView
            selectedParty = parties[indexPath.row]
            self.performSegueWithIdentifier(partyDetailSegueIdentifier, sender: self)
        } else {
            // some sort of inconsistency between tableView and party data
            selectedParty = nil
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(PartiesDataStore.sharedInstance.nearbyParties.count, minimumCellsInListView)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(minimumCellsInListView)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView: MKAnnotationView
        
        
        if let reusedPartyAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(partyAnnotationReuseIdentifier) {
            annotationView = reusedPartyAnnotationView
            annotationView.annotation = annotation
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: partyAnnotationReuseIdentifier)
        }
        
        // set up callout to have a rightward arrow
        let detailDisclosure: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        detailDisclosure.setImage(UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("disclosure_indicator", ofType: "png")!), forState: UIControlState.Normal)
        detailDisclosure.frame = CGRectMake(0,0,31,31)
        detailDisclosure.userInteractionEnabled = true
        annotationView.rightCalloutAccessoryView = detailDisclosure
        
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let partyAnnotation = view.annotation as? PartyAnnotation {
            if let party = partyAnnotation.party {
                // segue to part detail when clicking on party annotation
                self.selectedParty = party
                self.performSegueWithIdentifier(partyDetailSegueIdentifier, sender: self)
            }
        }
    }
    
    
    // MARK: - Login
    
    func launchLoginDialog() {
        let loginDialog = UIAlertController(title: "Create a new party", message: "Log in with Facebook to get started", preferredStyle: UIAlertControllerStyle.Alert)
        
        loginDialog.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            // Clicking the login alert will simulate a click to the FB login button
            self.fbLoginButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }))
        
        loginDialog.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            // Clicking cancel will dismiss the login dialog
            loginDialog.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(loginDialog, animated: true, completion: nil)
    }
    
    func loginDidSucceed() {
        println("login did succeed")
        // Now we need to check for banned status to be safe
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.checkForBanned()
        }
    }
    
    func loginDidFail(error: NSError!) {
        println("failed to log in to server because \(error)")
        UIAlertView(title: "Uh-oh", message: "Failed to log in to our servers", delegate: nil, cancelButtonTitle: "Ok").show()
    }
    
    func findUserByFBToken(fbToken: String) {
        MainUser.loginWithFBToken({ (err) -> Void in
            if err != nil {
                // FB logged in but failed on servers
                self.loginDidFail(err)
            } else {
                // logged in and got our user data
                self.performSegueWithIdentifier(self.createPartySegueIdentifier, sender: self)
            }
        })
    }
    
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //println("Downloaded access token for userId \(result.token.userID) with value \(result.token.tokenString)")
        if error != nil {
            self.loginDidFail(error)
        } else if result.isCancelled {
            // login was cancelled, ignore
        } else {
            findUserByFBToken(result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // TODO: support logout
    }
    
    
    // MARK: - CreatePartyViewControllerDelegate
    
    func createEditPartyDidCancel(viewController: CreateEditPartyViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createEditPartyDidSucceed(viewController: CreateEditPartyViewController, party: Party, method: CreateEditPartyActionType) {
        // reflect new party in the list
        self.listView?.reloadData()
        viewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // react to success differently based on HTTP method
            switch method {
            case .POST:
                self.selectedParty = party
                self.performSegueWithIdentifier(self.partyDetailSegueIdentifier, sender: self)
            case .PUT:
                break
            case .DELETE:
                break
            }
        })
    }
    
    
    // MARK: - Generic Selectors
    
    @IBAction func backBarItemClick(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func createPartyButtonClick(recognizer: UILongPressGestureRecognizer) {
        if recognizer === self.createPartyPressGestureRecognizer {
            // change alpha of the party hat if it was the sender
            switch recognizer.state {
            case .Began:
                self.createPartyBarButtonImageView?.alpha = 0.6
            case .Ended:
                self.createPartyBarButtonImageView?.alpha = 1.0
            case .Cancelled:
                self.createPartyBarButtonImageView?.alpha = 1.0
            default:
                break
            }
        }
        
        if recognizer.state == .Ended {
            if let currentFBToken = FBSDKAccessToken.currentAccessToken() {
                // we have a token locally
                let oneDaysTime = NSTimeInterval(60 * 60 * 24)
                let tomorrow = NSDate(timeIntervalSinceNow: +oneDaysTime)
                if (currentFBToken.expirationDate.timeIntervalSince1970 < tomorrow.timeIntervalSince1970) {
                    // time to renew the token
                    println("logging out to renew token")
                    FBSDKLoginManager().logOut()
                    self.launchLoginDialog()
                } else {
                    // user is already logged in
                    findUserByFBToken(currentFBToken.tokenString)
                }
            } else {
                // user is not logged in
                self.launchLoginDialog()
            }
        }
    }
    
    @IBAction func mapViewSegmentedControlClick(sender: AnyObject?) {
        if sender != nil && sender === useMapViewSegmentedControl {
            switch (useMapViewSegmentedControl!.selectedSegmentIndex) {
            case 0:
                // Switch to list
                self.mapView?.hidden = true
                self.listView?.hidden = false
            case 1:
                // Switch to map
                self.mapView!.removeAnnotations(self.mapView!.annotations)
                
                for party in PartiesDataStore.sharedInstance.nearbyParties {
                    // add party annotations
                    let point = PartyAnnotation()
                    point.party = party
                    
                    self.mapView?.addAnnotation(point)
                }
                
                self.listView?.hidden = true
                self.mapView?.hidden = false
                
                self.mapView!.showAnnotations(self.mapView!.annotations, animated: true)
            default:
                break
            }
        }
    }
    
    func requery() {
        // only requery if not already requerying
        if self.requeryLock.tryLock() {
            
            // lock UI elements that shouldn't be used during requery
            self.useMapViewSegmentedControl?.userInteractionEnabled = false
            
            
            
            PartiesDataStore.sharedInstance.requeryNearbyParties { (err, parties) -> Void in
                var errorAlertMsg: String?
                if err != nil {
                    // experienced an error during requery
                    println("reloadData error " + err!.description)
                    errorAlertMsg = "Oops, had trouble contacting the server"
                } else if PartiesDataStore.sharedInstance.nearbyParties.count == 0 {
                    // got no parties back
                    errorAlertMsg = "Looks like there aren't any parties going on near you"
                }
                
                self.refreshControl.endRefreshing()
                self.listView?.reloadData()
                
                if errorAlertMsg != nil {
                    // some kind of error happened, alert user
                    var cancelButtonTitle = "Ok "
                    cancelButtonTitle.append(SADFACE_CHAR)
                    
                    UIAlertView(title: "Uh oh", message: errorAlertMsg, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
                }
                // ALWAYS release lock and frozen UI
                self.requeryLock.unlock()
                self.useMapViewSegmentedControl?.userInteractionEnabled = true
            }
        }
    }
    
    
    // MARK: - Primitive Constants
    
    private let partyDetailSegueIdentifier = "PartyDetailSegue"
    private let createPartySegueIdentifier = "CreatePartySegue"
    private let minimumCellsInListView = 11
    private let partyCellReuseIdentifier = "PartySearchCell"
    private let fillerCellReuseIdentifier = "FillerCell"
    private let partyAnnotationReuseIdentifier = "PartyAnnotationView"
}




