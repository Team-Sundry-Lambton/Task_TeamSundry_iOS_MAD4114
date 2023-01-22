//
//  Place.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-22.
//

import Foundation
import MapKit
import CoreData

class Place: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    static func getLocationForAllTask(categoryName : String, context : NSManagedObjectContext) -> [Place] {
        var locationList = [TaskListObject]()
        let request: NSFetchRequest<TaskListObject> = TaskListObject.fetchRequest()
        let folderPredicate = NSPredicate(format: "parent_Category.name=%@", categoryName)
        request.predicate = folderPredicate
        do {
            locationList = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        var places = [Place]()
        
        for item in locationList {
            let title = item.name
            let subtitle = ""
            let latitude = item.latitude, longitude = item.longitude
            
            let place = Place(title: title, subtitle: subtitle, coordinate: CLLocationCoordinate2DMake(latitude, longitude))
            places.append(place)
        }
        
        return places as [Place]
    }
    
    static func getLocationForTask(task : TaskListObject) -> Place {
        let place = Place(title: task.name, subtitle: "", coordinate: CLLocationCoordinate2DMake(task.latitude, task.longitude))
        return place
    }
}

