//
//  ContactOrgCell.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 12..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import SwiftUI

class ContactOrgCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.titleLabel?.textColor = UIColor(Color.appNightText)
        self.valueLabel?.textColor = UIColor(Color.appNightText)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
