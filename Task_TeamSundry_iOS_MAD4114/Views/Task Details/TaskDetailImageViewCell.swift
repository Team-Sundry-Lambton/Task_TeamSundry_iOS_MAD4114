//
//  TaskDetailImageViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-23.
//

import Foundation
import UIKit

class TaskDetailImageViewCell : UICollectionViewCell{
    
    
    @IBOutlet weak var image: UIImageView!

    
    func configureCell(model:MediaFile){
        image.layer.cornerRadius = 12
            if let imageName = model.name{
                self.image.image = FolderManager.shared.getImageFromDocumentDirectory(fileName: imageName )
        }
    }
}
