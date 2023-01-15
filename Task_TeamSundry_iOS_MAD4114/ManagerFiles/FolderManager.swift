//
//  FolderManager.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-14.
//

import Foundation
import UIKit

class FolderManager{
    static let shared = FolderManager()
    var PorjectName : String = "FinalProject"
    let fileManager = FileManager.default
    
    func CreateFolderInDocumentDirectory()
    {
        let PathWithFolderName = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(PorjectName)
        
        print("Document Directory Folder Path :- ",PathWithFolderName)
        
        if !fileManager.fileExists(atPath: PathWithFolderName)
        {
            try! fileManager.createDirectory(atPath: PathWithFolderName, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func getProjectDirectoryPath() -> URL
    {
        let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let pathWithFolderName = documentDirectoryPath.appendingPathComponent(PorjectName)
    
        let url =  URL(fileURLWithPath: pathWithFolderName) // convert path in url
        
        return url
    }
    
    func clearAllInProjectFolder() {
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent(PorjectName)
        guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
    
    func CreateCategoryFolderInProjectDirectory(categoryID : String)
      {
          CreateFolderInDocumentDirectory()
          let url = self.getProjectDirectoryPath()
        
        let PathWithFolderName = url.appendingPathComponent(categoryID)
        
        print("Document Directory Folder Path :- ",PathWithFolderName.absoluteString)
            
        if !fileManager.fileExists(atPath: PathWithFolderName.absoluteString)
        {
            try! fileManager.createDirectory(at: PathWithFolderName, withIntermediateDirectories: true)
        }
      }
    
    func getCategoryDirectoryPath(categoryID : String) -> URL
    {
        let pathWithCategoryFolderName = getProjectDirectoryPath().appendingPathComponent(categoryID)
        return pathWithCategoryFolderName
    }
    
    func clearAllInCategoryFolder(categoryID : String) {
           let diskCacheStorageBaseUrl = getProjectDirectoryPath().appendingPathComponent(categoryID)
           guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
           for filePath in filePaths {
               try? fileManager.removeItem(at: filePath)
           }
       }
    
    func CreateFileFolderInCategoryDirectory(categoryID : String,fileID : String)
      {
          CreateCategoryFolderInProjectDirectory(categoryID :categoryID)
          let url = self.getCategoryDirectoryPath(categoryID: categoryID)
          let PathWithFolderName = url.appendingPathComponent(fileID)
        
        print("Document Directory Folder Path :- ",PathWithFolderName.absoluteString)
            
          if !fileManager.fileExists(atPath: PathWithFolderName.absoluteString)
        {
              try! fileManager.createDirectory(at: PathWithFolderName, withIntermediateDirectories: true)
        }
      }
    func getFileDirectoryPath(categoryID : String,fileID : String) -> URL
    {
        let pathWithFileFolderName = getCategoryDirectoryPath(categoryID: categoryID).appendingPathComponent(fileID)
        return pathWithFileFolderName
    }
    
    func clearAllInFileFolder(categoryID :String, fileID : String) {
           let diskCacheStorageBaseUrl = getCategoryDirectoryPath(categoryID: categoryID).appendingPathComponent(fileID)
           guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
           for filePath in filePaths {
               try? fileManager.removeItem(at: filePath)
           }
    }
    
    func saveImageDocumentDirectory(categoryID : String,fileID : String, fileName : String , image : UIImage) -> URL
    {
        CreateFileFolderInCategoryDirectory(categoryID: categoryID, fileID: fileID)
        let url = getFileDirectoryPath(categoryID: categoryID, fileID: fileID)
          
        let imagePath = url.appendingPathComponent(fileName)
        let urlString: String = imagePath.absoluteString
          

        let imageData = UIImage.pngData(image)
       
        fileManager.createFile(atPath: urlString as String, contents: imageData(), attributes: nil)
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
               try? imageData.write(to: imagePath, options: .atomic)
             
            }
        
        return imagePath
     }
    
    func getImageFromDocumentDirectory(categoryID : String,fileID : String,imageName : String) -> UIImage?
    {
        let imagePath = getFileDirectoryPath(categoryID: categoryID, fileID: fileID).appendingPathComponent(imageName)
        do {
                let imageData = try Data(contentsOf: imagePath)
                return UIImage(data: imageData)
            } catch {
                print("Error loading image : \(error)")
            }
            return nil
    }
    
    

}
