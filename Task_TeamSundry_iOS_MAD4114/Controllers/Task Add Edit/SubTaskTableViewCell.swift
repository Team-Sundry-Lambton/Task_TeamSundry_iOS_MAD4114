//
//  SubTaskTableViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Alice’z Poy on 2023-01-23.
//

import UIKit

protocol SubTaskTableViewCellDelegate {
    func subTaskDescriptionShouldBeginEditing(subTaskDescription: String, indexPath: IndexPath)
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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, let indexPath = indexPath {
            delegate?.subTaskDescriptionShouldBeginEditing(subTaskDescription: text, indexPath: indexPath)
        }
        return true
    }
}
