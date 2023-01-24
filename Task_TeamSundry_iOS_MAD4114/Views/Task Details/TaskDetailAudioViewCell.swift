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
    
    func configureCell(file: MediaFile?,isPlaying:Bool) {
        if let object = file {
            if(isPlaying){
                self.playPause.image = UIImage(systemName: "pause.circle.fill")
            }
            else{
                self.playPause.image = UIImage(systemName: "play.circle.fill")
            }
            
            self.audioTitle.text = "Name : " + (object.name ?? "")
        }
    }
    
}
