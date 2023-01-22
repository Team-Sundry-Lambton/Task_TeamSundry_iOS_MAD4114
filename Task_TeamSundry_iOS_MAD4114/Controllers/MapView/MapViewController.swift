//
//  MapViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-22.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func setSearchLocation(coordinate : CLLocationCoordinate2D,
                              title: String)
}

class MapViewController: UIViewController,CLLocationManagerDelegate,HandleMapSearch {

    @IBOutlet weak var mapView: MKMapView!
    var locationMnager = CLLocationManager()
    var destination : CLLocationCoordinate2D?
        
    var citySelection = false
    let selectLocation = false
    var resultSearchController: UISearchController!
    
    var selectedTask: TaskListObject?
    var selectedCategory: String?
    var places : [Place] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectLocation{
            mapView.isZoomEnabled = false
            addDoubleTap()
            
            let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
            resultSearchController = UISearchController(searchResultsController: locationSearchTable)
            resultSearchController.searchResultsUpdater = locationSearchTable
            let searchBar = resultSearchController!.searchBar
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for places"
            navigationItem.titleView = resultSearchController?.searchBar
            resultSearchController.hidesNavigationBarDuringPresentation = false
            resultSearchController.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            locationSearchTable.mapView = mapView
            locationSearchTable.handleLocationSearchDelegate = self
        }

        if let selectedFile = selectedTask {
            places.append(Place.getLocationForTask(task: selectedFile))
        }
        
        if let selectedCategory = selectedCategory {
            places = Place.getLocationForAllTask(categoryName: selectedCategory,context: context)
        }
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Double Tap
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        citySelection = true
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        self.displayLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "Task Location")
        destination = coordinate
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String) {
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - didupdatelocation method
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        removePin()

        let userLocation = locations[0]        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        self.displayLocation(latitude: latitude, longitude: longitude, title: "User Location")
    }
    
    func setSearchLocation(coordinate : CLLocationCoordinate2D,
                           title: String){
        citySelection = true
        self.displayLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, title: title)
        destination = coordinate
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

extension MapViewController: MKMapViewDelegate {
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        if citySelection {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }else{
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKMarkerAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }
    }
}
