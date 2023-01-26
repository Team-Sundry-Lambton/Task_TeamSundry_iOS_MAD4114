//
//  TaskDetailsViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//

import Foundation
import UIKit

class TaskDetailsViewController: UIViewController {
    
   
    var task:Task?
    var subTaskList = [SubTask]()
    var mediaList = [MediaFile]()
    var audioList = [MediaFile]()
        
    
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
    
    
    func getTask() -> Task {
        let task = Task(context: context)
        task.title = "Task Title Here"
        task.descriptionTask = "a quick brown fox jumps over the lazy dog."
        let location = Location(context: context)
        location.address = "New York"
        task.location = location
        
        return task
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData(task: getTask())
        
    }
    
    func initUI(){
        
        imageCollectionView.register(UINib.init(nibName: "TaskDetailImageViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskDetailImageViewCell")
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.reloadData()
        
        
        audioCollectionView.register(UINib.init(nibName: "TaskDetailAudioViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskDetailAudioViewCell")
        audioCollectionView.dataSource = self
        audioCollectionView.delegate = self
        audioCollectionView.reloadData()
        
        
        subTaskTableView.delegate = self
        subTaskTableView.dataSource = self
        
        
    }
    
    func initData(task:Task){
        locationLbl.text = task.location?.address
        taskTitleLbl.text = task.title
        descLbl.text = task.descriptionTask
        
        if(mediaList.isEmpty){
            imageView.isHidden = true
            imageCollectionView.isHidden = true
            noteImgIV.isHidden = true
        }
        else if(mediaList.count == 1){
            imageView.isHidden = false
            imageCollectionView.isHidden = true
            noteImgIV.isHidden = false
            noteImgIV.downloaded(from: mediaList[0].path ?? "")
            
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskDetailImageViewCell", for: indexPath) as! TaskDetailImageViewCell
            cell.configureCell(model: nil)
            return cell
            
        }
        
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskDetailAudioViewCell", for: indexPath) as! TaskDetailAudioViewCell
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
}


extension TaskDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTaskList.count
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


