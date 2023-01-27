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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
        
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
            let file = mediaList[indexPath.row]
            if let fileName = file.name {
                MediaManager.shared.audioPlaying(fileName: fileName,self){ success in
                    if success{
                        print("sucess")
                    }else{
                        print("error")
                    }
                }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTaskList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let model = subTaskList[indexPath.row]
        model.status = !model.status
        saveContextCoreData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subTaskCell", for: indexPath)
        let model = subTaskList[indexPath.row]
        cell.textLabel?.text = model.descriptionSubTask
        if(model.status){
            cell.imageView?.image = UIImage(named: "check")
        }
        else{
            cell.imageView?.image = UIImage(named: "uncheck")
        }
        
        return cell
    }
    
    
}


