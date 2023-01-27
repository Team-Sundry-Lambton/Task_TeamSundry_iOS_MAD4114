//
//  TaskDetailAudioViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-23.
//

import Foundation
import UIKit

class TaskDetailAudioViewCell:UICollectionViewCell{
    
    @IBOutlet weak var playPause: UIImageView!
    @IBOutlet weak var audioTitle: UILabel!
    
    func configureCell(file: MediaFile) {
        if let title = file.name {
            self.audioTitle.text = "Name : " + title
        }
    }
    
}
