//
//  SubTaskDetailViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-25.
//

import Foundation
import UIKit


class SubTaskCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    
    func configure(subTask:SubTask){
        if(subTask.status){
            self.checkBtn.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        }
        else{
            self.checkBtn.imageView?.image = UIImage(systemName: "checkmark.circle")
        }
    }
    func conf(status:Bool){
        if(status){
            self.checkBtn.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        }
        else{
            self.checkBtn.imageView?.image = UIImage(systemName: "checkmark.circle")
        }
    }
    
}
