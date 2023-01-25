//
//  TaskDetailsViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import Foundation
import UIKit

class TaskDetailsViewController: UIViewController {
    
   
    var task:Task?
    var subTaskList = [SubTask]()
    var mediaList = [MediaFile]()
    var audioList = [MediaFile]()
        
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getTask() -> Task {
        let task = Task(context: context)
        task.title = "Task Title Here"
        task.descriptionTask = "a quick brown fox jumps over the lazy dog."
        let location = Location(context: context)
        location.address = "New York"
        task.location = location
        
        return task
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib.init(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageTableViewCell")
        tableView.register(UINib.init(nibName: "DetailsViewCell", bundle: nil), forCellReuseIdentifier: "DetailsViewCell")
        tableView.register(UINib.init(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        tableView.register(UINib.init(nibName: "SubTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTaskTableViewCell")
        
    }

}


extension TaskDetailsViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as! ImageTableViewCell
            cell.setUp()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsViewCell") as! DetailsViewCell
            cell.configure(task: self.getTask())
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell") as! AudioTableViewCell
            cell.setUp()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTaskTableViewCell") as! SubTaskTableViewCell
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 180
        case 1:
            return 250
        case 2:
            return 70
        case 3:
            return (50 + 50*4)
        default:
            return 0
        }
    }
    
}


