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
}
