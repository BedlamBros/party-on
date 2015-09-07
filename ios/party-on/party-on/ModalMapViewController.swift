//
//  ModalMapViewController.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/3/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import MapKit

class ModalMapViewController: UIViewController {
    
    var annotations: [MKAnnotation]?
    
    weak var mapView: MKMapView?
    weak var backButton: UIButton?
    
    override func viewDidLoad() {
        let viewFrame = self.view.frame
        let mapView = MKMapView(frame: self.view.frame)
        self.mapView = mapView
        self.view.addSubview(mapView)
        
        if let backButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton {
            backButton.frame = CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.height, viewFrame.width * 0.3, viewFrame.height * 0.05)
            backButton.setTitle("Back", forState: UIControlState.Normal)
            backButton.titleLabel?.textColor = UIColor.blackColor()
            //backButton.backgroundColor = UIColor.blackColor()
            backButton.addTarget(self, action: "backButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.backButton = backButton
            self.view.addSubview(backButton)
        }
        
        if let annotations = self.annotations {
            self.mapView?.showAnnotations(annotations, animated: true)
        }
    }
    
    // MARK: - Generic Selectors
    
    func backButtonClick(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
