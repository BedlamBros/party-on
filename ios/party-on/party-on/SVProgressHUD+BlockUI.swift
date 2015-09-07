//
//  SVProgressHUD+BlockUI.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/3/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import Foundation
import SVProgressHUD

extension SVProgressHUD {
    
    // SVProgressHUD.show(), but block interaction with the view
    class func showAndBlockInteraction(view: UIView) {
        view.userInteractionEnabled = false
        self.show()
    }
    
    class func dismissAndUnblockInteraction(view: UIView) {
        view.userInteractionEnabled = true
        self.dismiss()
    }
}