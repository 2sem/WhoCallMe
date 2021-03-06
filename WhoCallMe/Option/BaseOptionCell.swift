//
//  BaseOptionCell.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 12..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class BaseOptionCell: UITableViewCell {

    var optionValue : Bool{
        get{
            var value = false;
            DispatchQueue.main.syncInMain { [unowned self] in
                value = self.optionValueSwitch.isOn;
            }
            
            return value;
        }
        
        set(value){
            self.optionValueSwitch.setOn(value, animated: true);
        }
    }
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionValueSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func toggle(){
        self.optionValueSwitch.setOn(!self.optionValueSwitch.isOn, animated: true);
    }
}
