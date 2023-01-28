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
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var mediaStackView: UIStackView!
    @IBOutlet weak var subTaskStackView: UIStackView!
    
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var buttonTableHeight: NSLayoutConstraint!
    
    //MARK: - Variables
    let datePicker: DatePicker = {
        let v = DatePicker()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var mediaList = [MediaFile]()
    
    var selectedLocation: Location?
    var subTasks = [SubTask]()
    var task: Task? {
        didSet {
            editMode = true
        }
    }
    var selectedDueDate: Date?
    var selectedCategory: Category?
    var addSubTaskCell = 1
    var editMode: Bool = false
    var addNote : Bool = false
    var dueDateString = "Today"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        
        view.addSubview(datePicker)
        
        configureDatePicker()
        configureView()
        
        if editMode{
            loadTaskData()
            loadMediaList()
            loadSubTaskList()
        }
        
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
        if addNote{
            buttonTableHeight.constant = CGFloat(105)
        }else{
            buttonTableHeight.constant = CGFloat(209)
        }
        
        if !editMode {
            createDateLabel.text = DatePicker.getStringCurrentDate()
            mediaStackView.isHidden = true
            subTaskStackView.isHidden = true
        }
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
    private func popupAlert(title: String, message: String , dissmossView : Bool) {
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default){
                UIAlertAction in
                if dissmossView {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            controller.addAction(okAction)
            return controller
        }()
        present(alertController, animated: true)
    }
    
    private func checkInput() -> Bool {
        if titleTextField.text == "" {
            popupAlert(title : "Error",message: "Please fill title of task", dissmossView: false)
            return false
        } else if descriptionTextView.text == "" {
            popupAlert(title : "Error",message: "Please fill description of task", dissmossView: false)
            return false
        } else {
            return true
        }
    }
    
    private func saveTask() {
        if checkInput() {
            if editMode {
                if let selectedTask = task {
                    context.delete(selectedTask)
                }
                for  media in self.mediaList {
                    context.delete(media)
                }
                
                for  subTask in self.subTasks {
                    context.delete(subTask)
                }
            }
            let newTask = Task(context: context)
            newTask.createDate = Date()
            newTask.parent_Category = selectedCategory
            newTask.title = titleTextField.text
            newTask.descriptionTask = descriptionTextView.text ?? ""
            newTask.dueDate = selectedDueDate
            selectedLocation?.task = newTask
            newTask.status = false
            
            
            for  media in self.mediaList {
                let mediaFile = MediaFile(context: context)
                mediaFile.parent_Task = newTask
                mediaFile.name = media.name
                mediaFile.isImage = media.isImage
                mediaFile.path = media.path
            }
            
            for  subTask in self.subTasks {
                let newSubTask = SubTask(context: context)
                newSubTask.status = subTask.status
                newSubTask.descriptionSubTask = subTask.descriptionSubTask
                newSubTask.task = newTask
            }
            if addNote{
                newTask.isTask = false
            }else{
                newTask.isTask = true
            }
            saveAllContextCoreData()
        }
    }
    
    private func openMapView() {
        let mapViewController:MapViewController = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        mapViewController.delegate = self
        mapViewController.selectLocation = true
        navigationController?.pushViewController(mapViewController, animated: true)
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
                strongSelf.saveSingleCoreData()
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
        mediaFileCollectionView.reloadData()
    }
    
    
    func deleteSubTask(subTask: SubTask) {
        context.delete(subTask)
    }
    
    //MARK: - Core data interaction methods
    
    // load folder from core data
    private func loadMediaList() {
        let request: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
        if let title = task?.title {
            let folderPredicate = NSPredicate(format: "parent_Task.title=%@", title)
            request.predicate = folderPredicate
        }
        do {
            mediaList = try context.fetch(request)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        if mediaList.count > 0{
            
            mediaFileCollectionView.reloadData()
            mediaStackView.isHidden = false
        }else{
            
            mediaStackView.isHidden = true
        }
    }
    
    private func loadSubTaskList() {
        let request: NSFetchRequest<SubTask> = SubTask.fetchRequest()
        if let title = task?.title {
            let folderPredicate = NSPredicate(format: "task.title=%@", title)
            request.predicate = folderPredicate
        }
        do {
            subTasks = try context.fetch(request)
        } catch {
            print("Error loading subTasks \(error.localizedDescription)")
        }
        if subTasks.count > 0{
            subTaskTableView.reloadData()
            subTaskStackView.isHidden = false
        }else{
            subTaskStackView.isHidden = true
        }
    }
    
    private func getLocationData() {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        if let title = task?.title {
            let folderPredicate = NSPredicate(format: "task.title=%@", title)
            request.predicate = folderPredicate
        }
        do {
            let location = try context.fetch(request)
            selectedLocation = location.first
        } catch {
            print("Error loading location data \(error.localizedDescription)")
        }
    }
    
    private func loadTaskData() {
        if let task = task {
            self.titleTextField.text = task.title
            self.descriptionTextView.text = task.descriptionTask
            if let createdDate = task.createDate{
                createDateLabel.text = DatePicker.getStringFromDate(date: createdDate)
            }
            if let dueDate = task.dueDate{
                buttonTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = DatePicker.getStringFromDate(date: dueDate)
                dueDateString = DatePicker.getStringFromDate(date: dueDate)
            }
            getLocationData()
            let locationRow = addNote ? 0 : 1
            buttonTableView.cellForRow(at: IndexPath(row: locationRow, section: 0))?.detailTextLabel?.text = selectedLocation?.address
        }
        
    }
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
            clearFieldAndNavigateBack()
            popupAlert(title : "Success",message: "Successfully Saved..", dissmossView: true)
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    private func saveSingleCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    private func clearFieldAndNavigateBack(){
        titleTextField.text = ""
        descriptionTextView.text = ""
        mediaList.removeAll()
        mediaFileCollectionView.reloadData()
        subTasks.removeAll()
        subTaskTableView.reloadData()
        buttonTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = dueDateString
        buttonTableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = "Current Location"
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
            return addNote ? 2 : 4
        } else {
            subTaskTableHeight.constant = CGFloat(((subTasks.count) + addSubTaskCell) * 50)
            return (subTasks.count) + addSubTaskCell// count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var id = "cell1"
        
        if tableView == buttonTableView {
            if addNote {
                switch indexPath.row {
                case 0:
                    id = "cell2"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id)
                    cell?.detailTextLabel?.text = selectedLocation?.address
                    return cell ?? UITableViewCell()
                case 1:
                    id = "cell3"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id) as? ButtonTableViewCell
                    cell?.statusSwitch.isOn = mediaList.count > 0 ? true : false
                    return cell ?? UITableViewCell()
                default:
                    break
                }
            }else{
                switch indexPath.row {
                case 0:
                    id = "cell1"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id)
                    cell?.detailTextLabel?.text = dueDateString
                    return cell ?? UITableViewCell()
                case 1:
                    id = "cell2"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id)
                    cell?.detailTextLabel?.text = selectedLocation?.address ?? "Curent Location"
                    return cell ?? UITableViewCell()
                case 2:
                    id = "cell3"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id) as? ButtonTableViewCell
                    cell?.statusSwitch.isOn = mediaList.count > 0 ? true : false
                    return cell ?? UITableViewCell()
                case 3:
                    id = "cell4"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id) as? ButtonTableViewCell
                    cell?.statusSwitch.isOn = subTasks.count > 0 ? true : false
                    return cell ?? UITableViewCell()
                default:
                    break
                }
            }
        } else {
            if indexPath.row == (subTasks.count) {
                id = "addSubTaskCell"
            } else {
                let subTask = subTasks[indexPath.row]
                id = "subTaskCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: id) as? SubTaskTableViewCell
                cell?.delegate = self
                cell?.indexPath = indexPath
                cell?.subTaskDescription.text = subTask.descriptionSubTask
                return cell ?? UITableViewCell()
            }
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: id) else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == buttonTableView {
            if addNote {
                if indexPath.row == 0 { //due date
                    print("location click")
                    openMapView()
                }
            }else{
                if indexPath.row == 0 { //due date
                    print("due date click")
                    datePicker.isHidden = false
                } else if indexPath.row == 1 { //location
                    print("location click")
                    openMapView()
                }
            }
        } else {
            if indexPath.row == (subTasks.count) { //Add subtask
                print("Add subtask")
                let subtask = SubTask(context: self.context)
                subtask.status = false
                subTasks.append(subtask)
                let indexPath:IndexPath = IndexPath(row:((self.subTasks.count) - addSubTaskCell), section: 0)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == subTaskTableView {
            if indexPath.row != (subTasks.count) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
            deleteSubTask(subTask: subTasks[indexPath.row])
            saveSingleCoreData()
            subTasks.remove(at: indexPath.row)
            let indexPath:IndexPath = IndexPath(row:indexPath.row, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == subTaskTableView {
            if indexPath.row != (subTasks.count) {
                return .delete
            } else {
                return .none
            }
        } else {
            return .none
        }
    }
}

//MARK: - MapViewDelegate
extension TaskAddEditViewController: MapViewDelegate {
    func setTaskLocation(place : PlaceObject){
        selectedLocation = Location(context: context)
        selectedLocation?.latitude = place.coordinate.latitude
        selectedLocation?.longitude = place.coordinate.longitude
        selectedLocation?.address = place.title
        let row = addNote ? 0 : 1
        buttonTableView.cellForRow(at: IndexPath(row: row, section: 0))?.detailTextLabel?.text = place.title
        
    }
}

extension TaskAddEditViewController: SubTaskTableViewCellDelegate {
    func subTaskDescriptionShouldChangeCharactersIn(subTaskDescription: String, indexPath: IndexPath) {
        subTasks[indexPath.row].descriptionSubTask = subTaskDescription
    }
}
