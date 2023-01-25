//
//  MediaFileCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-18.
//

import UIKit

class MediaFileCell: UICollectionViewCell {

    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var mediaName: UILabel!
    @IBOutlet weak var removeIcon: UIImageView!
    
    class var reuseIdentifier: String {
        return "MediaFileCell"
    }
    class var nibName: String {
        return "MediaFileCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(file: MediaFile? , indexPath :IndexPath) {
        if indexPath.row == 0 {
            self.mediaImage.image = UIImage(named: "AddMedia")
            self.mediaName.text = ""
            removeIcon.isHidden = true

        }else{
            if let object = file {
                removeIcon.isHidden = false
                if (object.isImage){
                    self.mediaImage.image =  FolderManager.shared.getImageFromDocumentDirectory(fileName: object.name ?? "")
                    self.mediaName.text = ""
                }else{
                    self.mediaImage.image = UIImage(named: "AddVoiceIcon")
                    self.mediaName.text = "Name : " + (object.name ?? "")
                }
            }
        }
    }
}
