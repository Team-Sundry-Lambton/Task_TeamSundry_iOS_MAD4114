//
//  TaskDetailsViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import Foundation
import UIKit
import CoreData

class TaskDetailsViewController: UIViewController {
    
    
    var task:Task?
    var subTaskList = [SubTask]()
    var mediaList = [MediaFile]()
    var audioList = [MediaFile]()
    var selectedLocation: Location?
    var selectedAudioFile = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isPlaying = false
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var audioCollectionView: UICollectionView!
    
    
    @IBOutlet weak var subTaskStack: UIStackView!
    @IBOutlet weak var subTaskTableView: UITableView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var noteImgIV: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var taskTitleLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var createdDateLbl: UILabel!
    @IBOutlet weak var dueDateLbl: UILabel!
    @IBOutlet weak var dueDateTitleLbl: UILabel!
    @IBOutlet weak var locationView: UIView!
    
    @IBOutlet weak var subTaskTableHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isPlaying {
            playAudio(fileName: selectedAudioFile)
        }
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func initUI(){
        
        imageCollectionView.register(UINib.init(nibName: "TaskDetailImageViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskDetailImageViewCell")
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        audioCollectionView.register(UINib.init(nibName: "TaskDetailAudioViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskDetailAudioViewCell")
        audioCollectionView.dataSource = self
        audioCollectionView.delegate = self
        
        subTaskTableView.delegate = self
        subTaskTableView.dataSource = self
    }
    
    func initData(){
        
        guard let task = task  else {
            return
        }
        
        locationLbl.text = task.location?.address
        taskTitleLbl.text = task.title
        descLbl.text = task.descriptionTask
        if let createdDate = task.createDate{
            createdDateLbl.isHidden = false
            createdDateLbl.text = DatePicker.getStringFromDate(date: createdDate)
        }
        else{
            createdDateLbl.isHidden = true
        }
        if let dueDate = task.dueDate{
            dueDateLbl.isHidden = false
            dueDateTitleLbl.isHidden = false
            dueDateLbl.text = DatePicker.getStringFromDate(date: dueDate)
        }else{
            dueDateLbl.isHidden = true
            dueDateTitleLbl.isHidden = true
        }
        
        getLocationData()
        loadMediaList()
        loadAudioList()
        loadSubTaskList()
        
        if(mediaList.isEmpty){
            imageView.isHidden = false
            imageCollectionView.isHidden = true
            noteImgIV.isHidden = true
        }
        else if(mediaList.count == 1){
            imageView.isHidden = false
            imageCollectionView.isHidden = true
            noteImgIV.isHidden = false
            if let imageName = mediaList[0].name{
                noteImgIV.image = FolderManager.shared.getImageFromDocumentDirectory(fileName: imageName )
            }
        }
        else{
            imageView.isHidden = false
            imageCollectionView.isHidden = false
            noteImgIV.isHidden = true
        }
        
        if(audioList.isEmpty){
            audioCollectionView.isHidden = true
        }
        else{
            audioCollectionView.isHidden = false
        }
        
        if(subTaskList.isEmpty){
            subTaskStack.isHidden = true
        }
        else{
            subTaskStack.isHidden = false
        }
        
        if (selectedLocation != nil){
            locationView.isHidden = false
        }else{
            locationView.isHidden = true
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
    
    private func loadMediaList() {
        let request: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
        if let title = task?.title {
            let folderPredicate = NSPredicate(format: "parent_Task.title=%@ AND isImage=true", title)
            request.predicate = folderPredicate
        }
        do {
            mediaList = try context.fetch(request)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        if mediaList.count > 0{
            imageCollectionView.reloadData()
            imageCollectionView.isHidden = false
        }else{
            imageCollectionView.isHidden = true
        }
    }
    
    private func loadAudioList() {
        let request: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
        if let title = task?.title {
            let folderPredicate = NSPredicate(format: "parent_Task.title=%@ AND isImage=false", title)
            request.predicate = folderPredicate
        }
        do {
            audioList = try context.fetch(request)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        if audioList.count > 0{
            audioCollectionView.reloadData()
            audioCollectionView.isHidden = false
        }else{
            audioCollectionView.isHidden = true
        }
    }
    
    private func loadSubTaskList() {
        let request: NSFetchRequest<SubTask> = SubTask.fetchRequest()
        if let title = task?.title {
            let folderPredicate = NSPredicate(format: "task.title=%@", title)
            request.predicate = folderPredicate
        }
        do {
            subTaskList = try context.fetch(request)
        } catch {
            print("Error loading subTasks \(error.localizedDescription)")
        }
        if subTaskList.count > 0{
            subTaskTableView.reloadData()
            subTaskTableView.isHidden = false
            subTaskStack.isHidden = false
        }else{
            subTaskTableView.isHidden = true
            subTaskStack.isHidden = true
        }
    }
    
    @IBAction func navigateToMapView(){
           let storyBoard : UIStoryboard = UIStoryboard(name: "MapView", bundle:nil)
           let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
           nextViewController.selectedTask = task
           nextViewController.selectLocation = false
            self.present(nextViewController, animated: true)
        
    }
    
    private func markSubTaskCompleteConfirmation(subTask: SubTask) {
        var message = ""
        if(subTask.status){
            message = "This task is already completed. Are you sure you want to mark this as incomplete?"
        }else{
            message = "Are you sure you want to complete this task?"
        }
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Warning", message: message , preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Yes", style: .default){
                UIAlertAction in
                subTask.status = !subTask.status
                self.task?.status = false
                self.saveContextCoreData()
            }
            controller.addAction(deleteAction)
            controller.addAction(cancelAction)
            return controller
        }()
        self.present(alertController, animated: true)
    }
    
}


extension TaskDetailsViewController :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.imageCollectionView){
            return mediaList.count
        }
        else{
            return audioList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.imageCollectionView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskDetailImageViewCell", for: indexPath) as? TaskDetailImageViewCell ?? TaskDetailImageViewCell()
            let mediaFile = mediaList[indexPath.row]
            cell.configureCell(model: mediaFile)
            return cell
        }
        
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskDetailAudioViewCell", for: indexPath) as? TaskDetailAudioViewCell ?? TaskDetailAudioViewCell()
            let audioFile = audioList[indexPath.row]
            cell.configureCell(file: audioFile)
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == imageCollectionView){
            return CGSize.init(width: 150, height: 180)
        }
        else{
            return CGSize.init(width: 75, height: 75)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == self.audioCollectionView){
            let file = audioList[indexPath.row]
            if let fileName = file.name {
                selectedAudioFile = fileName
                playAudio(fileName: selectedAudioFile)
            }
        }
    }
    
    private func playAudio(fileName : String){
        isPlaying = true
        MediaManager.shared.audioPlaying(fileName: fileName,self){ success in
            if success{
                print("sucess")
                self.isPlaying = false
            }else{
                print("error")
                self.isPlaying = false
            }
        }
    }
}


extension TaskDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    private func saveContextCoreData(){
        do{
            try context.save()
            loadSubTaskList()
        }
        catch{
            print("Error saving data \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subTaskTableHeight.constant = CGFloat(subTaskList.count * 150)
        return subTaskList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let model = subTaskList[indexPath.row]
        markSubTaskCompleteConfirmation(subTask: model)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subTaskCell", for: indexPath) as? SubTaskDetailTableViewCell
        let model = subTaskList[indexPath.row]
        if(model.status){
            cell?.subTaskStatusImage?.image = UIImage(named: "check")
            cell?.subTaskTitle?.textColor = .lightGray
            cell?.subTaskTitle?.text = model.descriptionSubTask ?? ""
            cell?.subTaskStatus.text = "Completed"
        }
        else{
            cell?.subTaskStatusImage?.image = UIImage(named: "uncheck")
            cell?.subTaskTitle?.textColor = .black
            cell?.subTaskTitle?.text = model.descriptionSubTask
            cell?.subTaskStatus.text = ""
        }
        
        return cell ?? UITableViewCell()
    }
}


