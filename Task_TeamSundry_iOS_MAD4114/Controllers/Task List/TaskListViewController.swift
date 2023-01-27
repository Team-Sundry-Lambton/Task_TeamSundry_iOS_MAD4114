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
    var selectedCategory: Category?
    var subTasks = [SubTask]()
    
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
               
        showSearchBar()
        showMoreSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTasks()
    }
    
    //MARK: - Core data interaction functions
    func loadTasks(predicate: NSPredicate? = nil , sortKey : String = "title") {
        tasks.removeAll()
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let folderPredicate = NSPredicate(format: "parent_Category.name=%@", selectedCategory!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
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
        searchController.searchBar.placeholder = "Search Task or Note"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    //MARK: - show empty table view
    func showNoTaskView(){
        if tasks.count == 0 {
            tableView.isHidden = true
            noTaskView.isHidden = false
        }else{
            tableView.isHidden = false
            noTaskView.isHidden = true
            taskTotalCount.title = "\(tasks.count) Tasks"
        }
        
        taskToolbar.isHidden = tableView.isHidden
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
                             self.sortCLicked()
                }),
                UIAction(title: "View on map ",
                         image: UIImage(systemName: "map.circle.fill")?.withTintColor(#colorLiteral(red: 0.4109354019, green: 0.4765244722, blue: 0.9726889729, alpha: 1) , renderingMode: .alwaysOriginal),
                         handler: { (_) in
                             self.openMapVC()
                })
            ]
        }

        var demoMenu: UIMenu {
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        showMoreBtn.menu = demoMenu
        
    }
    
    private func openTaskAddEditView(addNote : Bool, task : Task?) {
        let taskAddEditViewController:TaskAddEditViewController = UIStoryboard(name: "TaskAddEdit", bundle: nil).instantiateViewController(withIdentifier: "TaskAddEditView") as? TaskAddEditViewController ?? TaskAddEditViewController()
        taskAddEditViewController.addNote = addNote
        if let selectedTask = task {
            taskAddEditViewController.task = selectedTask
        }
        taskAddEditViewController.selectedCategory = selectedCategory
        navigationController?.pushViewController(taskAddEditViewController, animated: true)
    }
    
    
    @IBAction func addTaskBtnAction(_ sender: UIBarButtonItem) {
        addNoteOrTask()
    }
    
    
    @IBAction func getStartedBtnAction() {
        addNoteOrTask()
    }
    
    private func addNoteOrTask(){
        
        let alert = UIAlertController(title: "Select Option ", message: "Please select the option to continue", preferredStyle: .actionSheet)
        let taskAction = UIAlertAction(title: "Add Task", style: .default) { (action) in
            self.openTaskAddEditView(addNote: false, task: nil)
        }
        
        let noteAction = UIAlertAction(title: "Add Note", style: .default) { (action) in
            self.openTaskAddEditView(addNote: true, task: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(taskAction)
        alert.addAction(noteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
    
    //MARK: fetch sub tasks by task title
    private func loadOpenSubTaskList(title: String) {
        let request: NSFetchRequest<SubTask> = SubTask.fetchRequest()
        let folderPredicate = NSPredicate(format: "status=false AND task.title=%@", title)
        request.predicate = folderPredicate
        
        do {
            subTasks = try context.fetch(request)
        } catch {
            print("Error loading subTasks \(error.localizedDescription)")
        }
    }
    
    //MARK: prepare segue for move
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MoveTaskViewController {
            if let index = tableView.indexPathsForSelectedRows {
                let rows = index.map {$0.row}
                destination.selectedTasks = rows.map {tasks[$0]}
                destination.delegate = self
            }
        }
    }
    
    //MARK: prepare task details view controller
    func openTaskDetailVC(indexPath: IndexPath) {
        let viewController:TaskDetailsViewController = UIStoryboard(name: "TaskDetails", bundle: nil).instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailsViewController ?? TaskDetailsViewController()
        viewController.task = tasks[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: prepare map view
    func openMapVC() {
        let viewController:MapViewController = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        viewController.selectedCategory = selectedCategory
        self.present(viewController, animated: true)
    }
    
    private func sortCLicked() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to sort", preferredStyle: .actionSheet)

           let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
               print("Cancel")
           }
        actionSheetController.addAction(cancelActionButton)

           let saveActionButton = UIAlertAction(title: "By Title", style: .default)
               { _ in
                   self.loadTasks(predicate: nil , sortKey: "title")
           }
        actionSheetController.addAction(saveActionButton)

           let deleteActionButton = UIAlertAction(title: "By Created Date", style: .default)
               { _ in
                   self.loadTasks(predicate: nil , sortKey: "createDate")
           }
        actionSheetController.addAction(deleteActionButton)
           self.present(actionSheetController, animated: true, completion: nil)
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

        if !task.isTask {
            let image = UIImageView(image: UIImage(named: "isNote"))
            cell.accessoryView = image
        } else if task.status {
            let image = UIImageView(image: UIImage(named: "TaskDone"))
            cell.accessoryView = image
        } else {
            cell.accessoryView = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //MARK: swipe left action
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
            var selectedTask = self.tasks[indexPath.row]
            let addNote = selectedTask.isTask ? false : true
            self.openTaskAddEditView(addNote: addNote , task: selectedTask)
        }
       EditItem.backgroundColor = UIColor.systemBlue
        
       let swipeActions = UISwipeActionsConfiguration(actions: [DeleteItem,EditItem])

       return swipeActions
   }
    
    //MARK: swipe right action
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedTask = self.tasks[indexPath.row]
        if selectedTask.isTask {
            var bgColor = UIColor()
            var bgImage = UIImage()
            if !selectedTask.status {
                bgImage = UIImage(named: "doneTask") ?? UIImage()
                bgColor = #colorLiteral(red: 0.05831826478, green: 0.8438417912, blue: 0.004987356719, alpha: 1)
            }else{
                bgImage = UIImage(named: "undoneTask") ?? UIImage()
                bgColor = #colorLiteral(red: 1, green: 0.8123160005, blue: 0.3646123409, alpha: 1)
            }
            
            let markDone = UIContextualAction(style: .normal, title: nil ) {  (contextualAction, view, boolValue) in
                self.loadOpenSubTaskList(title: selectedTask.title ?? "")
                if self.subTasks.count > 0 {
                    let alert = UIAlertController(title: "Something went wrong!", message: "Please make sure all sub tasks are done", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let newStatus = !selectedTask.status
                    selectedTask.status = newStatus
                    self.saveTasks()
                }
                
                self.loadTasks()
            }
            
            markDone.image = bgImage
            markDone.backgroundColor = bgColor
            
            let swipeActions = UISwipeActionsConfiguration(actions: [markDone])
            return swipeActions
        }
        else{
            return nil
        }
        
    }
    
    //MARK: redirect task to task detail view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !deletingMovingOption{
            openTaskDetailVC(indexPath: indexPath)
        }
    }

    
}


//MARK: - search bar delegate methods
extension TaskListViewController: UISearchBarDelegate {
    
    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            loadTasks()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR descriptionTask CONTAINS[cd] %@", searchBar.text!, searchBar.text!)
            loadTasks(predicate: predicate)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            loadTasks()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR descriptionTask CONTAINS[cd] %@", searchBar.text!, searchBar.text!)
            loadTasks(predicate: predicate)
        }
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
        }else{
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR descriptionTask CONTAINS[cd] %@", searchBar.text!, searchBar.text!)
            loadTasks(predicate: predicate)
        }
    }
}

