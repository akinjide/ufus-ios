//
//  HistoryTableViewCell.swift
//  ufus
//
//  Created by Akinjide Bankole on 10/10/17.
//  Copyright © 2017 Akinjide Bankole. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var historyTitle: UILabel!
    @IBOutlet weak var historySubtitle: UILabel!
    @IBOutlet weak var historyTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
