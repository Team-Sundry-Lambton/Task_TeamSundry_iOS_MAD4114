//
//  SubTaskTableViewCell.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Tilak Acharya on 2023-01-25.
//

import Foundation
import UIKit

class SubTaskTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var subTask:[SubTask]?{
        didSet{
            collectionView.reloadData()
        }
    }
    
    func setUp(){
        collectionView.register(UINib.init(nibName: "SubTaskCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubTaskCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
}

extension SubTaskTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images?.count ?? 0
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubTaskCollectionViewCell", for: indexPath) as! SubTaskCollectionViewCell
        cell.conf(status: true)
//        cell.configureCell(model:images![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 200, height: 50)
    }
    

}
