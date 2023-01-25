//
//  ImageTableView.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-23.
//

import Foundation
import UIKit

class ImageTableViewCell : UITableViewCell{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images:[MediaFile]?{
        didSet{
            collectionView.reloadData()
        }
    }
    
    func setUp(){
        collectionView.register(UINib.init(nibName: "TaskDetailImageViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskDetailImageViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
}

extension ImageTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images?.count ?? 0
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskDetailImageViewCell", for: indexPath) as! TaskDetailImageViewCell
        cell.configureCell(model: nil)
//        cell.configureCell(model:images![indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 150, height: 180)
    }
}

