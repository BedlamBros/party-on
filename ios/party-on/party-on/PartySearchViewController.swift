//
//  PartySearchViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class PartySearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet var listView: UITableView?
    var mapView: MKMapView?
    @IBOutlet weak var useMapViewSegmentedControl: UISegmentedControl?
    weak var refreshControl: UIRefreshControl!
    
    private var nearbyParties: [Party] = []
    private var listOrMapViewFrame: CGRect = CGRectMake(0, 0, 0, 0)
    private weak var selectedParty: Party?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listView?.dataSource = self
        self.listView?.delegate = self
        
        let myframe = self.view.frame
        
        if let t = self.listView {
            self.listOrMapViewFrame = t.frame
        }
        self.mapView = MKMapView(frame: self.listOrMapViewFrame)
        self.mapView?.delegate = self
        
        let tableRefreshControl = UIRefreshControl()
        tableRefreshControl.backgroundColor = UIColor.purpleColor()
        tableRefreshControl.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = tableRefreshControl
        self.listView?.addSubview(tableRefreshControl)
        
        let partyJsonArray = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("parties", ofType: "json")!)!)["parties"].arrayValue
        
        // initialize with dummy parties
        self.nearbyParties = Array(map(partyJsonArray, { (singlePartyJson: JSON) -> Party in
            Party(json: singlePartyJson)
        }))
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
        }
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.nearbyParties.count {
            // selecting a party from the tableView
            selectedParty = self.nearbyParties[indexPath.row]
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
        return self.nearbyParties.count
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let partyAnnotationReuseIdentifier = "PartyAnnotationView"
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
    
    
    // MARK: - Generic Selectors
    
    @IBAction func backBarItemClick(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func mapViewSegmentedControlClick(sender: AnyObject?) {
        if sender != nil && sender === useMapViewSegmentedControl {
            switch (useMapViewSegmentedControl!.selectedSegmentIndex) {
            case 0:
                // Switch to list
                self.mapView?.removeFromSuperview()
                self.view.addSubview(self.listView!)
            case 1:
                // Switch to map
                self.mapView!.removeAnnotations(self.mapView!.annotations)
                
                for party in self.nearbyParties {
                    // add party annotations
                    let point = PartyAnnotation()
                    point.party = party
                    
                    self.mapView?.addAnnotation(point)
                }
                
                self.listView?.removeFromSuperview()
                self.view.addSubview(self.mapView!)
                self.mapView!.showAnnotations(self.mapView!.annotations, animated: true)
            default:
                break
            }
        }
    }
    
    func reloadData() {
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "didFinishRequerying", userInfo: nil, repeats: false)
    }
    
    func didFinishRequerying() {
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Primitive Constants
    
    private let partyDetailSegueIdentifier = "PartyDetailSegue"
}




