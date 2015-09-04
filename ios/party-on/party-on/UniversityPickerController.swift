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
    
    @IBOutlet weak var indianaUniversityLogo: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let preferredUniversity = University.getStoredUniversityPreference() {
            // bypass this controller if university preference is already set
            University.currentUniversity = preferredUniversity
            if let searchPartiesController = self.storyboard?.instantiateViewControllerWithIdentifier(searchPartyStoryboardIdentifier) as? PartySearchViewController {
                self.navigationController?.pushViewController(searchPartiesController, animated: false)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        
        let clickUniversityGestureRecognizer = UITapGestureRecognizer(target: self, action: "selectUniversity:")
        self.indianaUniversityLogo?.addGestureRecognizer(clickUniversityGestureRecognizer)
        
        let viewFrame = self.view.frame
        let titleFrameVertPercentage: CGFloat = 0.1
        let titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, viewFrame.width, viewFrame.height * titleFrameVertPercentage))
        titleLabel.text = "Pick your University"
        self.view.addSubview(titleLabel)
        
        super.viewWillAppear(animated)
    }
    
    func selectUniversity(sender: AnyObject?) {
        if let sendingView = sender?.view {
            if sendingView === self.indianaUniversityLogo {
                University.currentUniversity = University.universityForType(UniversityType.IndianaUniversity)
            }
            self.performSegueWithIdentifier(enterAppSegueIdentifier, sender: self)
        }
    }
    
    private let enterAppSegueIdentifier = "EnterAppSegueAnimated"
    private let searchPartyStoryboardIdentifier = "SearchPartiesController"
}
