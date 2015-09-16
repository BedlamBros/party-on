//
//  TheWordTableViewCell.swift
//  party-on
//
//  Created by Maxwell McLennan on 9/10/15.
//  Copyright (c) 2015 Maxwell McLennan. All rights reserved.
//

import UIKit

class TheWordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bodyLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dateLabel?.textColor = UIColor.grayColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
