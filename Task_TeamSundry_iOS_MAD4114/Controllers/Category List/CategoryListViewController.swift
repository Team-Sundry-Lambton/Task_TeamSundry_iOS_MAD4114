//
//  CategoryListViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import Foundation
import UIKit

class CategoryListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loadAddEditPage() {
        let viewController:UIViewController = UIStoryboard(name: "TaskAddEdit", bundle: nil).instantiateViewController(withIdentifier: "TaskAddEditView") as UIViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it

        self.present(viewController, animated: false, completion: nil)
    }
    

}
