//
//  TaskAddEditViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import UIKit
import CoreData

class TaskAddEditViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var subTaskTableHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTableView: UITableView!
    @IBOutlet weak var subTaskTableView: UITableView!
    
    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var mediaStackView: UIStackView!
    @IBOutlet weak var subTaskStackView: UIStackView!
    
    @IBOutlet weak var createDateLabel: UILabel!
    
    //MARK: - Variables
    let datePicker: DatePicker = {
        let v = DatePicker()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var mediaList = [MediaFile]()
    var selectedFile: MediaFile? {
        didSet {
            loadMediaList()
        }
    }
    
    var selectedLocation: Location?
    var subTasks = [SubTask]()
    var task: Task?
    var selectedDueDate: Date?
    var category: Category?
    var addSubTaskCell = 1
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        
        view.addSubview(datePicker)
        
        loadMediaList()
        configureDatePicker()
        configureView()
    }
    
    private func registerNib() {
        let nib = UINib(nibName: MediaFileCell.nibName, bundle: nil)
        mediaFileCollectionView?.register(nib, forCellWithReuseIdentifier: MediaFileCell.reuseIdentifier)
        if let flowLayout = self.mediaFileCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    //MARK: - Configure View
    private func configureView() {
        createDateLabel.text = DatePicker.getStringCurrentDate()
        mediaStackView.isHidden = true
        subTaskStackView.isHidden = true
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
        datePicker.dismissClosure = { [weak self] pickedDate in
            guard let strongSelf = self else {
                return
            }
            strongSelf.datePicker.isHidden = true
            strongSelf.buttonTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = DatePicker.getStringFromDate(date: pickedDate)
            strongSelf.selectedDueDate = pickedDate
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func saveAction(_ sender: Any) {
        saveTask()
    }
    
    @IBAction func mediaSwitchAction(_ sender: UISwitch) {
        mediaStackView.isHidden = !sender.isOn
    }
    
    @IBAction func subTaskSwitchAction(_ sender: UISwitch) {
        subTaskStackView.isHidden = !sender.isOn
    }
    
    
    //MARK: - View Controller Logic
    private func popupAlert(message: String) {
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            controller.addAction(okAction)
            return controller
        }()
        present(alertController, animated: true)
    }
    
    private func checkInput() -> Bool {
        if titleTextField.text == "" {
            popupAlert(message: "Please fill title of task")
            return false
        } else if descriptionTextField.text == "" {
            popupAlert(message: "Please fill description of task")
            return false
        } else {
            return true
        }
    }
    
    private func saveTask() {
        if checkInput() {
            task?.createDate = Date()
            task?.parent_Category = category
            task?.title = titleTextField.text
            task?.descriptionTask = descriptionTextField.text ?? ""
            task?.dueDate = selectedDueDate
            task?.location = selectedLocation
            task?.status = false
            if !mediaStackView.isHidden {
                task?.medias = NSSet(array: mediaList)
            }
            
            if !subTaskStackView.isHidden {
                task?.subtasks = NSSet(array: subTasks)
            }
            
            saveAllContextCoreData()
        }
    }
    
    private func openMapView() {
        let mapViewController:MapViewController = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        mapViewController.delegate = self
        present(mapViewController, animated: true)
    }
    
    //MARK: - Media Logic
    private func addMediaFile() {
        MediaManager.shared.pickMediaFile(self) { [weak self] mediaObject in
            guard let strongSelf = self else {
                return
            }
            
            if let object = mediaObject {
                let mediaFile = MediaFile(context: strongSelf.context)
                mediaFile.name = object.fileName
                mediaFile.isImage = object.isImage
                mediaFile.path = object.filePath
                strongSelf.mediaList.append(mediaFile)
                strongSelf.saveAllContextCoreData()
                strongSelf.mediaFileCollectionView.reloadData()
            }
        }
    }
    
    private func deleteMediaFileConfirmation(mediaFile: MediaFile, indexPath: IndexPath) {
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
    
    private func deleteMediaFile(mediaFile: MediaFile) {
        FolderManager.shared.clearSelectedFile(filePath: mediaFile.path ?? "")
        context.delete(mediaFile)
        saveAllContextCoreData()
        mediaFileCollectionView.reloadData()
    }
    
    //MARK: - Core data interaction methods
    
    // load folder from core data
    private func loadMediaList() {
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
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving the folder \(error.localizedDescription)")
        }
    }
}

//MARK: - UICollectionViewDataSource & UICollectionViewDelegate
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

//MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskAddEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == buttonTableView {
            return 4
        } else {
            subTaskTableHeight.constant = CGFloat(((subTasks.count) + addSubTaskCell) * 50)
            return (subTasks.count) + addSubTaskCell// count
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
            if indexPath.row == (subTasks.count) {
                id = "addSubTaskCell"
            } else {
                id = "subTaskCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: id) as? SubTaskTableViewCell
                cell?.delegate = self
                cell?.indexPath = indexPath
                return cell ?? UITableViewCell()
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
                openMapView()
            }
        } else {
            if indexPath.row == (subTasks.count) { //Add subtask
                print("Add subtask")
                subTasks.append(SubTask())
                let indexPath:IndexPath = IndexPath(row:((self.subTasks.count) - addSubTaskCell), section: 0)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
}

//MARK: - MapViewDelegate
extension TaskAddEditViewController: MapViewDelegate {
    func setTaskLocation(latitude : Double , logtitude : Double){
        selectedLocation?.latitude = latitude
        selectedLocation?.longitude = logtitude
    }
}

extension TaskAddEditViewController: SubTaskTableViewCellDelegate {
    func subTaskDescriptionShouldBeginEditing(subTaskDescription: String, indexPath: IndexPath) {
        subTasks[indexPath.row].descriptionSubTask = subTaskDescription
    }
}
