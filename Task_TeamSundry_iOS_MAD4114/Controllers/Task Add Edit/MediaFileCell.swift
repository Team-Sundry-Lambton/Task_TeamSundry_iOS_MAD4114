//
//  MediaFileCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-18.
//

import UIKit

class MediaFileCell: UICollectionViewCell {

    @IBOutlet weak var mediaImage: UIImageView!
    
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
    
    func configureCell(fileID : String, categoryID : String,file: MediaFile? , indexPath :IndexPath) {
        if indexPath.row == 0 {
            self.mediaImage.image = UIImage(named: "Image")

        }else{
            if let object = file {
                if (object.isImage){
                    self.mediaImage.image =  FolderManager.shared.getImageFromDocumentDirectory(categoryID: categoryID,fileID: fileID,fileName: object.name ?? "")
                }else{
                    self.mediaImage.image = UIImage(named: "Image")
                }
            }
        }
    }
}
