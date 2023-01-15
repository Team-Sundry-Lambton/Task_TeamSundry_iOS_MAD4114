//
//  MediaManager.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-14.
//

import Foundation
import UIKit

class MediaManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    static let shared = MediaManager()
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image to Add", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    
    var pickMediaCallback : ((MediaReturnObject?) -> ())?;
    var categoryID : String = ""
    var fileID : String = ""
    var fileName : String = ""
    
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }

        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((MediaReturnObject?) -> ())) {
        pickMediaCallback = callback;
        self.viewController = viewController;

        alert.popoverPresentationController?.sourceView = self.viewController!.view

        viewController.present(alert, animated: true, completion: nil)
    }
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
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
        self.viewController!.present(picker, animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //for swift below 4.2
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //    picker.dismiss(animated: true, completion: nil)
    //    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    //    pickImageCallback?(image)
    //}
    
    // For Swift 4.2+
    func imagePickerController1(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        fileName = generateFileName(audioFile: false)
        let url = FolderManager.shared.saveImageDocumentDirectory(categoryID: categoryID, fileID: fileID, fileName : fileName, image: image)
        let object  = MediaReturnObject(fileName: fileName, image: image, filePath: url.absoluteString)
        pickMediaCallback?(object)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        fileName = generateFileName(audioFile: false)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let url = FolderManager.shared.saveImageDocumentDirectory(categoryID: categoryID, fileID: fileID, fileName : fileName, image: image)
        let object  = MediaReturnObject(fileName: fileName, image: image, filePath: url.absoluteString)
        pickMediaCallback?(object)
        picker.dismiss(animated: true, completion: nil)
        
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
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
}
