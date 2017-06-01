//
//  SectionHeaderTableViewCell.swift
//  TechNiche
//
//  Created by Manas Mishra on 01/06/17.
//  Copyright © 2017 Manas Mishra. All rights reserved.
//

import UIKit

class SectionHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var content: UIView!

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
