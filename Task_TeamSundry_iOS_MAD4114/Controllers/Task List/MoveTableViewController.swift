//
//  MoveTableViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Sonia Nain on 2023-01-25.
//

import UIKit
import CoreData

class MoveTaskViewController: UIViewController {
    
    var categories = [Category]()
    var selectedTasks: [Task]? {
        didSet {
            loadCategories()
        }
    }
    
    weak var delegate: TaskListViewController?
    
    // context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - core data interaction methods
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        // predicate
        let folderPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedTasks?[0].parent_Category?.name ?? "")
        request.predicate = folderPredicate
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
    }
    

    @IBAction func dismissVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension MoveTaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "move_cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move to \(categories[indexPath.row].name ?? "")", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
            if let selectedTasks = self.selectedTasks {
                for task in selectedTasks {
                    task.parent_Category = self.categories[indexPath.row]
                }
                // dismiss the vc
                self.dismiss(animated: true, completion: nil)
                self.delegate?.saveTasks()
                self.delegate?.loadTasks()
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        noAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    
}
