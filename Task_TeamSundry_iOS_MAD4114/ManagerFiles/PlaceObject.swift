//
//  PlaceObject.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-22.
//

import Foundation
import MapKit
import CoreData

class PlaceObject: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    static func getLocationForAllTask(categoryName : String, context : NSManagedObjectContext) -> [PlaceObject] {
        var places = [PlaceObject]()
        var taskTitle = ""
        let taskList = getTaskList(categoryName: categoryName,context: context)
        for task in taskList {
            let request: NSFetchRequest<Location> = Location.fetchRequest()
            if let title = task.title {
                taskTitle = title
                let folderPredicate = NSPredicate(format: "task.title=%@", taskTitle)
                request.predicate = folderPredicate
            }
            do {
               let location = try context.fetch(request)
                if let item = location.first {
                    let subtitle = item.address
                    let latitude = item.latitude, longitude = item.longitude
                    
                    let place = PlaceObject(title: taskTitle, subtitle: subtitle, coordinate: CLLocationCoordinate2DMake(latitude, longitude))
                    places.append(place)
                }
            } catch {
                print("Error loading folders \(error.localizedDescription)")
            }
        }
        
        return places as [PlaceObject]
    }
    
    static func getTaskList (categoryName : String, context : NSManagedObjectContext) -> [Task]{
        var taskList = [Task]()
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let folderPredicate = NSPredicate(format: "parent_Category.name=%@", categoryName)
        request.predicate = folderPredicate
        do {
            taskList = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        return taskList
    }
    
    static func getLocationForTask(task : Task, context: NSManagedObjectContext) -> PlaceObject? {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        var taskTitle = ""
        if let title = task.title {
            taskTitle = title
            let folderPredicate = NSPredicate(format: "task.title=%@", title)
            request.predicate = folderPredicate
        }
        
        do {
           var location = try context.fetch(request)
            return PlaceObject(title:taskTitle, subtitle: location.first?.address, coordinate: CLLocationCoordinate2DMake(location.first?.latitude ?? 0, location.first?.longitude ?? 0))
            
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        return nil

    }
}

