//
//  TaskListViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Sonia Nain on 2023-01-24.
//

import UIKit
import CoreData

class TaskListViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskTotalCount: UIBarButtonItem!
    @IBOutlet weak var addTaskBtn: UIBarButtonItem!
    @IBOutlet weak var noTaskView: UIView!
    @IBOutlet weak var taskToolbar: UIToolbar!
    @IBOutlet weak var showMoreBtn: UIBarButtonItem!
    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var moveBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    
    
    var tasks = [Task]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTasks()
    }
    
    //MARK: - Core data interaction functions
    func loadTasks(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate])
        }
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error loading tasks \(error.localizedDescription)")
        }
        
        tableView.reloadData()
        
    }
    
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task_cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.descriptionTask

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
}

