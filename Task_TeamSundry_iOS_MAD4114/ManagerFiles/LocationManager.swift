//
//  LocationManager.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Alice’z Poy on 2023-01-22.
//

import Foundation
import UIKit
import CoreData

class LocationManager {
    
    static func getLocationFromTask(task: Task, context : NSManagedObjectContext) -> Location {
        var location = Location()
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        let locationPredicate = NSPredicate(format: "location.id=%@", task.locationID)
        request.predicate = locationPredicate
        do {
            location = try context.fetch(request).first ?? Location()
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        return location
    }
}
