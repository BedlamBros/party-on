//
//  UniversityPickerController.swift
//  party-on
//
//  Created by Maxwell McLennan on 8/31/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit

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
    
}
