//
//  buttonTableViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-27.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextLbl: UILabel!
    @IBOutlet weak var detailTextLbl: UILabel!
    @IBOutlet weak var subTaskDescription: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
