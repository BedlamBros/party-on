//
//  UniversityPickerController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit
import CoreLocation

class UniversityPickerController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        
        let viewFrame = self.view.frame
        let titleFrameVertPercentage: CGFloat = 0.1
        let titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, viewFrame.width, viewFrame.height * titleFrameVertPercentage))
        titleLabel.text = "Pick your University"
        self.view.addSubview(titleLabel)
        
        super.viewWillAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EnterAppSegue" {
            University.currentUniversity = University(name: "Indiana University", location: CLLocationCoordinate2D(latitude: 39.1691355, longitude: -86.5149053))
        }
    }
    
}
