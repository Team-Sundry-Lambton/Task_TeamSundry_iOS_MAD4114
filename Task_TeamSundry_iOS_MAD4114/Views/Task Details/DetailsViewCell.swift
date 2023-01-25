//
//  DetailsViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-23.
//

import Foundation
import UIKit
import CoreData

class DetailsViewCell : UITableViewCell{
    
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var taskTitle: UILabel!
    
    @IBOutlet weak var taskCreatedDate: UILabel!
    
    @IBOutlet weak var taskDueDate: UILabel!
    
    @IBOutlet weak var taskDescription: UILabel!
    
    func configure(task:Task){
        locationBtn.setTitle(task.location?.address, for: .normal)
        taskTitle.text = task.title
//        taskCreatedDate.text = task.createDate?.description
//        taskDueDate.text = task.dueDate?.description
        taskDescription.text = task.descriptionTask
    }
    
}
