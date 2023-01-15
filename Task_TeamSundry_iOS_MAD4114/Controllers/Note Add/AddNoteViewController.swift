//
//  AddNoteViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-14.
//

import UIKit

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var urlLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pickImage(_ sender: Any) {
        MediaManager.shared.categoryID = "Category"
        MediaManager.shared.fileID = "FIle"
        MediaManager.shared.pickImage(self){ mediaObject in
            if let object = mediaObject {
                self.imageView.image =  FolderManager.shared.getImageFromDocumentDirectory(categoryID: "Category",fileID: "FIle",imageName: object.fileName)  // mediaObject.image
                self.urlLbl.text = object.filePath
            }
            }
    }
    
    @IBAction func recordAudioButtonTapped() {
        MediaManager.shared.categoryID = "Category"
        MediaManager.shared.fileID = "FIle"
            recordButton.setTitle("Tap to Stop", for: .normal)
            playButton.isEnabled = false
        MediaManager.shared.audioRecording(self){ mediaObject in
            if let object = mediaObject{
                self.recordButton.setTitle("Tap to Record", for: .normal)
                self.playButton.isEnabled = true
                self.recordButton.isEnabled = true
                self.urlLbl.text = object.filePath
            }else{
                self.recordButton.setTitle("Rerecord Record", for: .normal)
                self.playButton.isEnabled = false
            }
        }
    }
    
    @IBAction func playAudioButtonTapped(_ sender: UIButton) {
        sender.setTitle("Stop", for: .normal)
        recordButton.isEnabled = false
        MediaManager.shared.audioPlaying(fileName: self.urlLbl.text!,self){ success in
            if success{
                sender.setTitle("Play", for: .normal)
                self.recordButton.isEnabled = true
            }else{
               //error
            }
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
