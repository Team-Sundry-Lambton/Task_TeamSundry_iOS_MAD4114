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
        conf(status: subTask.status)
    }
    func conf(status:Bool){
        if(status){
            self.checkBtn.imageView?.image = UIImage(named: "check")
        }
        else{
            self.checkBtn.imageView?.image = UIImage(named: "uncheck")
        }
    }
    
}
