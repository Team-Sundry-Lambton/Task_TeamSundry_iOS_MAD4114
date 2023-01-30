//
//  SubTaskTableViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Alice’z Poy on 2023-01-23.
//

import UIKit

protocol SubTaskTableViewCellDelegate {
    func subTaskDescriptionShouldChangeCharactersIn(subTaskDescription: String, indexPath: IndexPath)
}

class SubTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var subTaskDescription: UITextField!
    var delegate: SubTaskTableViewCellDelegate?
    var indexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subTaskDescription.delegate = self
    }
}

extension SubTaskTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let indexPath = indexPath {
            delegate?.subTaskDescriptionShouldChangeCharactersIn(subTaskDescription: text, indexPath: indexPath)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
