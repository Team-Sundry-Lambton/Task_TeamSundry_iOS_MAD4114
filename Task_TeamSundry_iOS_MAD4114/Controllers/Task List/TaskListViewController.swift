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
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    var tasks = [Task]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // define a search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    var deletingMovingOption: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStartedBtn.layer.cornerRadius = 10
        moveBtn.isHidden = true
        deleteBtn.isHidden = true
        doneBtn.isHidden = true
        
        loadTasks()
        showSearchBar()
        showMoreSettings()
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
        showNoTaskView()
        
    }
    
    //MARK: - show search bar func
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Task"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    //MARK: - show empty table view
    func showNoTaskView(){
        if tasks.count == 0 {
            tableView.backgroundView = noTaskView
            taskToolbar.isHidden = true
        }else{
            tableView.backgroundView = nil
            taskToolbar.isHidden = false
            taskTotalCount.title = "\(tasks.count) Tasks"
        }
    }
    
    //MARK: - show empty table view
    func showMoreSettings() {
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Select Tasks",
                         image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(#colorLiteral(red: 0.4109354019, green: 0.4765244722, blue: 0.9726889729, alpha: 1) , renderingMode: .alwaysOriginal),
                         handler: { (_) in
                         
                             self.showHideToolbarOptions()
                            
                }),
                UIAction(title: "Sort By",
                         image: UIImage(systemName: "arrow.up.arrow.down.circle.fill")?.withTintColor(#colorLiteral(red: 0.4109354019, green: 0.4765244722, blue: 0.9726889729, alpha: 1) , renderingMode: .alwaysOriginal),
                         handler: { (_) in
                }),
                UIAction(title: "View on map ",
                         image: UIImage(systemName: "map.circle.fill")?.withTintColor(#colorLiteral(red: 0.4109354019, green: 0.4765244722, blue: 0.9726889729, alpha: 1) , renderingMode: .alwaysOriginal),
                         handler: { (_) in
                })
            ]
        }

        var demoMenu: UIMenu {
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        showMoreBtn.menu = demoMenu
        
    }
    
    private func openTaskAddEditView() {
        let taskAddEditViewController:TaskAddEditViewController = UIStoryboard(name: "TaskAddEdit", bundle: nil).instantiateViewController(withIdentifier: "TaskAddEditView") as? TaskAddEditViewController ?? TaskAddEditViewController()
        taskAddEditViewController.delegate = self
        navigationController?.pushViewController(taskAddEditViewController, animated: true)
    }
    
    
    @IBAction func addTaskBtnAction(_ sender: UIBarButtonItem) {
        openTaskAddEditView()
    }
    
    
    @IBAction func getStartedBtnAction() {
        openTaskAddEditView()
    }
    
    //MARK: - delete task
    func deleteTask(task: Task) {
        context.delete(task)
    }
    
    //MARK: - save task
    func saveTasks() {
        do {
            try context.save()
        } catch {
            print("Error saving the tasks \(error.localizedDescription)")
        }
    }
    
    func showHideToolbarOptions(){
        self.deletingMovingOption = !self.deletingMovingOption
        self.tableView.setEditing(self.deletingMovingOption, animated: true)
        if self.deletingMovingOption {
            self.moveBtn.isHidden = false
            self.deleteBtn.isHidden = false
            self.addTaskBtn.isHidden = true
            self.doneBtn.isHidden = false
            self.showMoreBtn.isHidden = true
        }else{
            self.moveBtn.isHidden = true
            self.deleteBtn.isHidden = true
            self.addTaskBtn.isHidden = false
            self.doneBtn.isHidden = true
            self.showMoreBtn.isHidden = false
        }
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            
            if indexPaths.count > 0 {
                let alert = UIAlertController(title: "Delete Task(s) ", message: "The task(s) will be removed and can not restore. Do you want to delete?", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    
                    let rows = (indexPaths.map {$0.row}).sorted(by: >)
                    
                    let _ = rows.map {self.deleteTask(task: self.tasks[$0])}
                    let _ = rows.map {self.tasks.remove(at: $0)}
                    self.saveTasks()
                    self.loadTasks()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        
        showHideToolbarOptions()
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       let DeleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
           
           let alert = UIAlertController(title: "Delete this task ", message: "Are you sure?", preferredStyle: .alert)
           let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
               self.deleteTask(task: self.tasks[indexPath.row])
               self.saveTasks()
               self.tasks.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
               self.loadTasks()
           }
           
           let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
           alert.addAction(yesAction)
           alert.addAction(noAction)
           self.present(alert, animated: true, completion: nil)
           
           
       }
        
        let EditItem = UIContextualAction(style: .normal , title: "Edit") {  (contextualAction, view, boolValue) in
            //Code I want to do here
        }
       EditItem.backgroundColor = UIColor.systemBlue
        
       let swipeActions = UISwipeActionsConfiguration(actions: [DeleteItem,EditItem])

       return swipeActions
   }
    
    
}


//MARK: - search bar delegate methods
extension TaskListViewController: UISearchBarDelegate {
    
    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadTasks(predicate: predicate)
    }
    
    
    /// when the text in text bar is changed
    /// - Parameters:
    ///   - searchBar: search bar is passed to this function
    ///   - searchText: the text that is written in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadTasks()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

