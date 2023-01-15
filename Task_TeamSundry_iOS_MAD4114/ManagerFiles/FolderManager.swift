//
//  FolderManager.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-14.
//

import Foundation

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
}
