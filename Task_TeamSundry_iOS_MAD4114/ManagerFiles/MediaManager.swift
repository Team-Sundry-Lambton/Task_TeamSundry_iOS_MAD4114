//
//  MediaManager.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-14.
//

import Foundation
import UIKit
import AVFoundation

class MediaManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    static let shared = MediaManager()
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Media file to Add", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    
    var pickMediaCallback : ((MediaReturnObject?) -> ())?;
    var categoryID : String = ""
    var fileID : String = ""
    var fileName : String = ""
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var playingCallback : ((Bool) -> ())?;
    
    //MARK: Image Selection
    override init(){
        super.init()
        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let voiceAction = UIAlertAction(title: "Record Voice", style: .default){
            UIAlertAction in
            self.startRecordingView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }

        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(voiceAction)
        alert.addAction(cancelAction)
    }
    
    func pickMediaFile(_ viewController: UIViewController, _ callback: @escaping ((MediaReturnObject?) -> ())) {
        pickMediaCallback = callback;
        self.viewController = viewController;

        alert.popoverPresentationController?.sourceView = self.viewController?.view

        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController?.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // For Swift 4.2+
    func imagePickerController1(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        fileName = generateFileName(audioFile: false)
        let imagePath = FolderManager.shared.saveImageDocumentDirectory(categoryID: categoryID, fileID: fileID, fileName : fileName, image: image)
        let object  = MediaReturnObject(fileName: fileName, image: image, filePath: imagePath.absoluteString, isImage: true)
        pickMediaCallback?(object)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        fileName = generateFileName(audioFile: false)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let url = FolderManager.shared.saveImageDocumentDirectory(categoryID: categoryID, fileID: fileID, fileName : fileName, image: image)
        let object  = MediaReturnObject(fileName: fileName, image: image, filePath: url.absoluteString, isImage: true)
        pickMediaCallback?(object)
        picker.dismiss(animated: true, completion: nil)
        
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
    //MARK: Audio Recording
    
    func startRecordingView(){
        if audioRecorder == nil {
            startRecording()
        }
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Recorder", message: "Please record your voice and once you finish Please press the 'Done' button ", preferredStyle: .alert)
           
            let voiceAction = UIAlertAction(title: "Done", style: .default){
                UIAlertAction in
                self.finishRecording(success: true)
            }
            controller.addAction(voiceAction)
            return controller
        }()
        viewController?.present(alertController, animated: true)
        
//        if audioRecorder == nil {
//            startRecording()
//        } else {
//           finishRecording(success: true)
//        }
    }
    
    func audioRecording(_ viewController: UIViewController, _ callback: @escaping ((MediaReturnObject?) -> ())) {
        pickMediaCallback = callback;
        if audioRecorder == nil {
            startRecording()
        } else {
           finishRecording(success: true)
        }
    }
    
    func audioPlaying(fileName : String,_ viewController: UIViewController, _ callback: @escaping ((Bool) -> ())) {
        playingCallback = callback;
        if audioPlayer == nil{
            startPlaying(fileName: fileName)
        } else {
            finishPlaying(success: true)
        }
    }
    
    func startRecording() {
        fileName = generateFileName(audioFile: true)
        let audioFilename = FolderManager.shared.getRecordingFileURL(categoryID: categoryID, fileID: fileID, fileName: fileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
            
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
            
        let filePath = FolderManager.shared.getRecordingFileURL(categoryID: categoryID, fileID: fileID, fileName: fileName).absoluteString
        let mediaObject  = MediaReturnObject(fileName: fileName, image: nil, filePath: filePath, isImage: false)
            
        if success {
            pickMediaCallback?(mediaObject)
        } else {
            pickMediaCallback?(nil)
        }
    }
    
    
    func preparePlayer(fileName : String) {
        var error: NSError?
        do {
            let audioFilename = URL(string: fileName)
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename!)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 10.0
        }
    }
    
    func startPlaying(fileName : String) {
        preparePlayer(fileName: fileName)
        audioPlayer?.play()
    }
    
    func finishPlaying(success: Bool) {
        audioPlayer?.stop()
        audioPlayer = nil
        if success {
            playingCallback?(true)
        } else {
            playingCallback?(false)
        }
    }
        
    //MARK: Audio Record Delegates
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error?.localizedDescription ?? "")")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            finishPlaying(success: false)
        }else{
            finishPlaying(success: true)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error?.localizedDescription ?? "")")
        print("Error while playing audio \(error?.localizedDescription ?? "")")
    }
            
    func generateFileName(audioFile : Bool) -> String{
        let id = UUID().uuidString
        if(audioFile){
            return  id + ".m4a"
        }else{
            return id + ".png"
        }
    }
}

struct MediaReturnObject{
    var fileName : String
    var image : UIImage?
    var filePath : String
    var isImage : Bool
}
