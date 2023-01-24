//
//  TaskDetailsViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import Foundation
import UIKit

class TaskDetailsViewController: UIViewController {
    
     
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskCreatedDate: UILabel!
    @IBOutlet weak var taskDueDate: UILabel!
    @IBOutlet weak var taskDescription: UILabel!
    
    @IBOutlet weak var audioFileCollectionView: UICollectionView!
    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    @IBOutlet weak var mediaStackView: UIStackView!
   
    var task:Task?
    var subTaskList = [SubTask]()
    var mediaList = [MediaFile]()
    var audioList = [MediaFile]()
    
    
    @IBOutlet weak var subTaskStackView: UIStackView!
    @IBOutlet weak var subTaskTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}



