//
//  TaskAddEditViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import UIKit

class TaskAddEditViewController: UIViewController {

    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        // Do any additional setup after loading the view.
    }
    
    func registerNib() {
        let nib = UINib(nibName: MediaFileCell.nibName, bundle: nil)
        mediaFileCollectionView?.register(nib, forCellWithReuseIdentifier: MediaFileCell.reuseIdentifier)
        if let flowLayout = self.mediaFileCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TaskAddEditViewController
: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaFileCell.reuseIdentifier,
                                                         for: indexPath) as? MediaFileCell {
        
           
            return cell
        }
        return UICollectionViewCell()
    }

}

extension TaskAddEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell: MediaFileCell = Bundle.main.loadNibNamed(MediaFileCell.nibName,
                                                                      owner: self,
                                                                      options: nil)?.first as? MediaFileCell else {
            return CGSize.zero
        }
    
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: size.width, height: 30)
    }
}
