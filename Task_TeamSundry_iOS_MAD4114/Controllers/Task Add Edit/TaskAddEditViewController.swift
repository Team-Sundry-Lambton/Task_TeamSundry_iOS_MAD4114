//
//  TaskAddEditViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import UIKit
import CoreData

class TaskAddEditViewController: UIViewController {

    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    
    var mediaList = [MediaFile]()
    var selectedFile: TaskListObject? {
        didSet {
            loadMediaList()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        
        let task = TaskListObject(context: self.context)
        task.name = "1"
        selectedFile = task
        self.saveMediaFile()
        
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
    
    
    func addMediaFile() {
        MediaManager.shared.pickMediaFile(self){ mediaObject in
            if let object = mediaObject {
                
                let mediaFile = MediaFile(context: self.context)
                mediaFile.name = object.fileName
                mediaFile.isImage = object.isImage
                mediaFile.path = object.filePath
                self.mediaList.append(mediaFile)
                self.saveMediaFile()
                
            }
        }
    }
    
    func deleteMediaFileConfirmation(mediaFile: MediaFile) {
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Warning", message: "Are you sure you want to delete this file", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Delete", style: .default){
                UIAlertAction in
                self.deleteMediaFile(mediaFile: mediaFile)
            }
            controller.addAction(deleteAction)
            controller.addAction(cancelAction)
            return controller
        }()
        self.present(alertController, animated: true)
      
    }
    
    //MARK: - core data interaction methods
    
    /// load folder from core data
    func loadMediaList() {
        let request: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
//        let folderPredicate = NSPredicate(format: "parent_Task.name=%@", FileId)
//        request.predicate = folderPredicate
        do {
            mediaList = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        mediaFileCollectionView.reloadData()
    }

    func saveMediaFile() {
        do {
            try context.save()
            mediaFileCollectionView.reloadData()
        } catch {
            print("Error saving the folder \(error.localizedDescription)")
        }
    }
    func deleteMediaFile(mediaFile: MediaFile) {
        FolderManager.shared.clearSelectedFile(filePath: mediaFile.name ?? "")
       context.delete(mediaFile)
        saveMediaFile()
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
             
            cell.configureCell(file: file,indexPath:indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.row == 0 {
            addMediaFile()
        }else{
            let file = mediaList[indexPath.row - 1]
            mediaList.remove(at: indexPath.row - 1)
            deleteMediaFileConfirmation(mediaFile: file)
        }
    }
}
