//
//  TaskAddEditViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import UIKit
import CoreData

class TaskAddEditViewController: UIViewController {

    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    
    var FileId : String = ""
    var CategoryId : String = ""
    
    var mediaList = [MediaFile]()
    var selectedFile: TaskListObject? {
        didSet {
            FileId = selectedFile!.name ?? ""
            CategoryId = ""
            loadMediaList()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        registerNib()
        loadMediaList()
        // Do any additional setup after loading the view.
    }
    
    func registerNib() {
        let nib = UINib(nibName: MediaFileCell.nibName, bundle: nil)
        mediaFileCollectionView?.register(nib, forCellWithReuseIdentifier: MediaFileCell.reuseIdentifier)
        if let flowLayout = self.mediaFileCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    
    //MARK: - core data interaction methods
    
    /// load folder from core data
    func loadMediaList() {
        let request: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
        let folderPredicate = NSPredicate(format: "parent_Task.name=%@", FileId)
        request.predicate = folderPredicate
        do {
            mediaList = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        mediaFileCollectionView.reloadData()
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
        return mediaList.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaFileCell.reuseIdentifier,
                                                         for: indexPath) as? MediaFileCell {
        
            let file = indexPath.row == 0 ? nil : mediaList[indexPath.row - 1];
             
            cell.configureCell(fileID: self.FileId, categoryID: self.CategoryId ,file: file,indexPath:indexPath)
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
        let file = indexPath.row == 0 ? nil : mediaList[indexPath.row - 1];
        cell.configureCell(fileID: self.FileId, categoryID: self.CategoryId ,file: file,indexPath:indexPath)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: size.width, height: 30)
    }
}
