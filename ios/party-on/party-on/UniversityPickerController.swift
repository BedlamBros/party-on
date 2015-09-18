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
    
    @IBOutlet weak var indianaUniversityButton: UIButton?
    @IBOutlet weak var backgroundImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let preferredUniversity = University.getStoredUniversityPreference() {
            // bypass this controller if university preference is already set
            University.currentUniversity = preferredUniversity
            if let searchPartiesController = self.storyboard?.instantiateViewControllerWithIdentifier(searchPartyStoryboardIdentifier) as? PartySearchViewController {
                self.navigationController?.pushViewController(searchPartiesController, animated: false)
            }
        }
        
        self.backgroundImageView?.contentMode = UIViewContentMode.ScaleToFill
        
        // Configure Indiana University button
        self.indianaUniversityButton?.layer.cornerRadius = 5
        self.indianaUniversityButton?.clipsToBounds = true
        
        // Configure title label
        let viewFrame = self.backgroundImageView!.frame
        let titleFrameVertPercentage: CGFloat = 0.1
        let titleFrameSideMargin: CGFloat = 0.05 * viewFrame.width
        let titleLabel = UILabel(frame: CGRectMake(titleFrameSideMargin, UIApplication.sharedApplication().statusBarFrame.height, viewFrame.width - (2 * titleFrameSideMargin), viewFrame.height * titleFrameVertPercentage))
        titleLabel.text = "Pick your University"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "Courier-Bold", size: 20)
        self.backgroundImageView!.addSubview(titleLabel)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        super.viewWillAppear(animated)
    }
    
    @IBAction func selectUniversity(sender: UIView) {
        if sender === self.indianaUniversityButton {
            University.currentUniversity = University.universityForType(UniversityType.IndianaUniversity)
            self.performSegueWithIdentifier(enterAppSegueIdentifier, sender: self)
        }
    }
    
    private let enterAppSegueIdentifier = "EnterAppSegueAnimated"
    private let searchPartyStoryboardIdentifier = "SearchPartiesController"
}
