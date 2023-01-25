//
//  AudioTableViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-25.
//

import Foundation
import UIKit

class AudioTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var audio:[MediaFile]?{
        didSet{
            collectionView.reloadData()
        }
    }
    
    
    func setUp(){
        collectionView.register(UINib.init(nibName: "TaskDetailAudioViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskDetailAudioViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
}

extension AudioTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images?.count ?? 0
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskDetailAudioViewCell", for: indexPath) as! TaskDetailAudioViewCell
//        cell.configureCell(model:images![indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 75, height: 75)
    }
}
