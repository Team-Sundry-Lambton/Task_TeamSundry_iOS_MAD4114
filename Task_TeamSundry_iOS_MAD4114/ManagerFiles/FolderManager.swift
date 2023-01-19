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
    var ProjectName : String = "FinalProject"
    let fileManager = FileManager.default
    
    func createFolderInDocumentDirectory()
    {
        let pathWithFolderName = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(ProjectName)
        
        createFolderIfNotExist(pathWithFolderName: pathWithFolderName)
    }
    
    func getProjectDirectoryPath() -> URL
    {
        let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let pathWithFolderName = documentDirectoryPath.appendingPathComponent(ProjectName)
    
        let url =  URL(fileURLWithPath: pathWithFolderName) // convert path in url
        
        return url
    }
    
    func clearAllInProjectFolder() {
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let diskCacheStorageBaseUrl = myDocuments?.appendingPathComponent(ProjectName) else { return  }
        removeAllFilesInPath(diskCacheStorageBaseUrl: diskCacheStorageBaseUrl)
    }
    
    func removeAllFilesInPath(diskCacheStorageBaseUrl : URL){
        guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
    
    func createFolderIfNotExist(pathWithFolderName : String){
        print("Document Directory Folder Path :- ",pathWithFolderName)
        
        if !fileManager.fileExists(atPath: pathWithFolderName)
        {
            try? fileManager.createDirectory(atPath: pathWithFolderName, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func createCategoryFolderInProjectDirectory(categoryID : String)
      {
          createFolderInDocumentDirectory()
          let url = self.getProjectDirectoryPath()
        
          let pathWithFolderName = url.appendingPathComponent(categoryID)
          
          createFolderIfNotExist(pathWithFolderName: pathWithFolderName.absoluteString)
      }
    
    func getCategoryDirectoryPath(categoryID : String) -> URL
    {
        let pathWithCategoryFolderName = getProjectDirectoryPath().appendingPathComponent(categoryID)
        return pathWithCategoryFolderName
    }
    
    func clearAllInCategoryFolder(categoryID : String) {
        let diskCacheStorageBaseUrl = getProjectDirectoryPath().appendingPathComponent(categoryID)
        
        removeAllFilesInPath(diskCacheStorageBaseUrl: diskCacheStorageBaseUrl)
    }
    
    func createFileFolderInCategoryDirectory(categoryID : String,fileID : String)
      {
          createCategoryFolderInProjectDirectory(categoryID :categoryID)
          let url = self.getCategoryDirectoryPath(categoryID: categoryID)
          let pathWithFolderName = url.appendingPathComponent(fileID)
        
          createFolderIfNotExist(pathWithFolderName: pathWithFolderName.absoluteString)
      }
    
    func getFileDirectoryPath(categoryID : String,fileID : String) -> URL
    {
        let pathWithFileFolderName = getCategoryDirectoryPath(categoryID: categoryID).appendingPathComponent(fileID)
        return pathWithFileFolderName
    }
    
    func clearAllInFileFolder(categoryID :String, fileID : String) {
           let diskCacheStorageBaseUrl = getCategoryDirectoryPath(categoryID: categoryID).appendingPathComponent(fileID)
        removeAllFilesInPath(diskCacheStorageBaseUrl: diskCacheStorageBaseUrl)
          
    }
    
    func saveImageDocumentDirectory(categoryID : String, fileID : String, fileName : String , image : UIImage) -> URL
    {
        createFileFolderInCategoryDirectory(categoryID: categoryID, fileID: fileID)
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
    
    func getImageFromDocumentDirectory(categoryID : String, fileID : String, fileName : String) -> UIImage?
    {
        let imagePath = getFileDirectoryPath(categoryID: categoryID, fileID: fileID).appendingPathComponent(fileName)
        do {
                let imageData = try Data(contentsOf: imagePath)
                return UIImage(data: imageData)
            } catch {
                print("Error loading image : \(error)")
            }
            return nil
    }
    
    func getRecordingFileURL(categoryID : String, fileID : String, fileName : String) -> URL {
        
        createFileFolderInCategoryDirectory(categoryID: categoryID, fileID: fileID)
        let url = FolderManager.shared.getFileDirectoryPath(categoryID: categoryID, fileID: fileID)
          
        let path = url.appendingPathComponent(fileName)
        return path
    }
    
    func clearSelectedFile(categoryID :String, fileID : String, fileName : String) {
        let diskCacheStorageBaseUrl = getFileDirectoryPath(categoryID: categoryID, fileID: fileID).appendingPathComponent(fileName)
        removeAllFilesInPath(diskCacheStorageBaseUrl: diskCacheStorageBaseUrl)
    }
}
