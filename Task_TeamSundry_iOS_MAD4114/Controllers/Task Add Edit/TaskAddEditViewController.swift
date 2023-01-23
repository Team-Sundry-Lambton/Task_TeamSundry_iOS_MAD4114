//
//  TaskAddEditViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import UIKit
import CoreData

class TaskAddEditViewController: UIViewController {
    
    @IBOutlet weak var subTaskTableHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTableView: UITableView!
    @IBOutlet weak var subTaskTableView: UITableView!
    
    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var mediaStackView: UIStackView!
    @IBOutlet weak var subTaskStackView: UIStackView!
    
    let datePicker: DatePicker = {
        let v = DatePicker()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var subTask:[String] = ["Sample1"]
    
    var mediaList = [MediaFile]()
    var selectedFile: MediaFile? {
        didSet {
            loadMediaList()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        
        view.addSubview(datePicker)
        
        let medies = MediaFile(context: self.context)
        medies.name = "1"
        selectedFile = medies
        self.saveMediaFile()
        
        loadMediaList()
        configureDatePicker()
    }
    
    private func configureDatePicker() {
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // custom picker view should cover the whole view
            datePicker.topAnchor.constraint(equalTo: g.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: g.bottomAnchor),
        ])
        
        // hide custom picker view
        datePicker.isHidden = true
        
        // add closures to custom picker view
        datePicker.dismissClosure = { [weak self] in
            guard let self = self else {
                return
            }
            self.datePicker.isHidden = true
        }
        
        datePicker.changeClosure = { [weak self] val in
            guard let self = self else {
                return
            }
            print(val)
            // do something with the selected date
        }
    }
    
    @IBAction func mediaSwitchAction(_ sender: UISwitch) {
        mediaStackView.isHidden = !sender.isOn
    }
    
    @IBAction func subTaskSwitchAction(_ sender: UISwitch) {
        subTaskStackView.isHidden = !sender.isOn
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
    
    func deleteMediaFileConfirmation(mediaFile: MediaFile, indexPath: IndexPath) {
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Warning", message: "Are you sure you want to delete this file", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Delete", style: .default){
                UIAlertAction in
                self.mediaList.remove(at: indexPath.row - 1)
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
        FolderManager.shared.clearSelectedFile(filePath: mediaFile.path ?? "")
        context.delete(mediaFile)
        saveMediaFile()
    }
    
    func setTaskLocation(latitude : Double , Logtitude : Double){
        
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
            deleteMediaFileConfirmation(mediaFile: file, indexPath: indexPath)
        }
    }
}

extension TaskAddEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == buttonTableView {
            return 4
        } else {
            subTaskTableHeight.constant = CGFloat((subTask.count + 1) * 50)
            return subTask.count + 1// count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var id = "cell1"
        
        if tableView == buttonTableView {
            switch indexPath.row {
            case 0:
                id = "cell1"
            case 1:
                id = "cell2"
            case 2:
                id = "cell3"
            case 3:
                id = "cell4"
            default:
                break
            }
        } else {
            if indexPath.row == (subTask.count + 1) - 1 {
                id = "addSubTaskCell"
            } else {
                id = "subTaskCell"
            }
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: id) else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == buttonTableView {
            if indexPath.row == 0 { //due date
                print("due date click")
                datePicker.isHidden = false
            } else if indexPath.row == 1 { //location
                print("location click")
            }
        } else {
            if indexPath.row == (subTask.count + 1) - 1 { //Add subtask
                print("Add subtask")
            }
        }
        
    }
}


