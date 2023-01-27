//
//  SubTaskDetailTableViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-27.
//

import UIKit

class SubTaskDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var subTaskTitle: UILabel!
    @IBOutlet weak var subTaskStatus: UILabel!
    @IBOutlet weak var subTaskStatusImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
