//
//  CategoryListViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import Foundation
import UIKit
import CoreData

class CategoryListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTaskView: UIView!
    
    // create a Category array to populate the table
    var categories = [Category]()
    
    // create a context to work with core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        showNoTaskView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - show empty table view
    func showNoTaskView() {
        if categories.count == 0 {
            tableView.isHidden = true
            noTaskView.isHidden = false
        }else{
            tableView.isHidden = false
            noTaskView.isHidden = true
        }
    }
    
    private func createNewCategory() {
        var textField = UITextField()
        let alert = UIAlertController(title: "New Category", message: "Please name it 🖌️", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            self.saveNewCategory(name: textField.text ?? "New Category")
        }
        
        // change the color of the cancel button action
        addAction.setValue(UIColor.green, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "category name"
        }
        
        present(alert, animated: true)
    }
    
    func editCategory(oldName: String, indexPath: IndexPath) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Edit Category Name", message: "Please name it 🖌️", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Done", style: .default) { (action) in
            //Code I want to do here
//            self.deleteCategory(category: self.categories[indexPath.row])
//            self.saveCategories()
//            self.categories.remove(at: indexPath.row)
//            // Delete the row from the data source
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
//            self.saveNewCategory(name: textField.text ?? "New Category")
        }
        
        // change the color of the cancel button action
        addAction.setValue(UIColor.green, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "category name"
            textField.text = oldName
        }
        
        present(alert, animated: true)
    }
    
    private func saveNewCategory(name _name: String) {
        var name = _name
        if name.isEmpty {
            name = "New Category"
        }
        
        let categoryNames = self.categories.map {$0.name?.lowercased()}
        guard !categoryNames.contains(name.lowercased()) else {self.showAlert(); return}
        let newCategory = Category(context: self.context)
        newCategory.name = name
        categories.append(newCategory)
        saveCategories()
    }
    
    private func updateCategory(newName _newName: String, indexPath: IndexPath) {
        var newName = _newName
        if newName.isEmpty {
            newName = "New Category"
        }
        
        let categoryNames = self.categories.map {$0.name?.lowercased()}
        guard !categoryNames.contains(newName.lowercased()) else {self.showAlert(); return}
        categories[indexPath.row].name = newName
        saveCategories()
    }
    
    /// show alert when the name of the Category is taken
    func showAlert() {
        let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func action(_ sender: Any) {
        createNewCategory()
    }
    
    func openTaskListVC(indexPath: IndexPath) {
        let viewController:TaskListViewController = UIStoryboard(name: "TaskList", bundle: nil).instantiateViewController(withIdentifier: "TaskListView") as? TaskListViewController ?? TaskListViewController()
        viewController.selectedCategory = categories[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - core data interaction methods
    
    /// load Category from core data
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    /// save Categorys into core data
    func saveCategories() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the Category \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(category: Category) {
        context.delete(category)
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category_cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openTaskListVC(indexPath: indexPath)
    }
    
    // to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextualAction, view, boolValue)  in
            guard let strongSelf = self else {
                return
            }
            //Code I want to do here
            strongSelf.deleteCategory(category: strongSelf.categories[indexPath.row])
            strongSelf.saveCategories()
            strongSelf.categories.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            strongSelf.showNoTaskView()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] (contextualAction, view, boolValue) in
            guard let strongSelf = self else {
                return
            }
            
        }
        editAction.backgroundColor = .blue
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])

        return swipeActions
    }
}
