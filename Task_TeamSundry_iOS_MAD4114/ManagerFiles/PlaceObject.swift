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
        var locationList = [Location]()
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        let folderPredicate = NSPredicate(format: "parent_Category.name=%@", categoryName)
        request.predicate = folderPredicate
        do {
            locationList = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        var places = [PlaceObject]()
        
        for item in locationList {
            let title = item.address
            let subtitle = ""
            let latitude = item.latitude, longitude = item.longitude
            
            let place = PlaceObject(title: title, subtitle: subtitle, coordinate: CLLocationCoordinate2DMake(latitude, longitude))
            places.append(place)
        }
        
        return places as [PlaceObject]
    }
    
    static func getLocationForTask(task : Task, context: NSManagedObjectContext) -> PlaceObject {
//        let place = PlaceObject(title: task.location?.address, subtitle: "", coordinate: CLLocationCoordinate2DMake(task.location?.latitude ?? 0, task.location?.longitude ?? 0))
//        return place
        return PlaceObject(title: "", subtitle: "", coordinate: CLLocationCoordinate2D())
    }
}

