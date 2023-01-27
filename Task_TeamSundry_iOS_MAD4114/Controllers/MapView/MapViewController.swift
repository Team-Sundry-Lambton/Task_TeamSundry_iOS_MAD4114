//
//  MapViewController.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Malsha Lambton on 2023-01-22.
//

import UIKit
import MapKit

protocol MapViewDelegate {
    func setTaskLocation(place:PlaceObject)
}

class MapViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationMnager = CLLocationManager()
    var destination : CLLocationCoordinate2D?
    var address : String = ""
        
    var citySelection = false
    var selectLocation = false
    var resultSearchController: UISearchController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedTask: Task?
    var selectedCategory: Category?
    var places : [PlaceObject] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: MapViewDelegate?
    
    @IBOutlet var currentLocationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        locationMnager.delegate = self
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()

        mapView.delegate = self
        
        if selectLocation{
            currentLocationBtn.setTitle("Use Current Location", for: .normal)
            mapView.isZoomEnabled = false
            addDoubleTap()
            setUpforSearch()
        }

        if let selectedTask = selectedTask {
            currentLocationBtn.setTitle("Done", for: .normal)
            if let place = PlaceObject.getLocationForTask(task: selectedTask, context: context) {
                places.append(place )
            }
        }
        
        if let selectedCategoryName = selectedCategory?.name {
            currentLocationBtn.setTitle("Done", for: .normal)
            places = PlaceObject.getLocationForAllTask(categoryName: selectedCategoryName,context: context)
        }
        // Do any additional setup after loading the view.
    }
    
    func setUpforSearch() {
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as? LocationSearchTableViewController ?? LocationSearchTableViewController()

        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        searchBar?.delegate = self
        searchBar?.isUserInteractionEnabled = true
        navigationItem.searchController = resultSearchController
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleLocationSearchDelegate = self
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
        
        getLocationAddressAndAddPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
        if selectLocation{
            destination = userLocation.coordinate
        }
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        getLocationAddressAndAddPin(latitude: latitude, longitude: longitude)
//        self.displayLocation(latitude: latitude, longitude: longitude, title: "User Location")
    }
    
    @IBAction func useCurrentLocation() {
        if selectLocation {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        }else{
            self.dismiss(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if selectLocation {
            if let destination = destination{
                let place = PlaceObject(title: address , subtitle: "", coordinate: destination)
                delegate?.setTaskLocation(place: place)
            }
        }
    }
    
    
    func getLocationAddressAndAddPin(latitude: CLLocationDegrees, longitude : CLLocationDegrees) {

            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = latitude
            center.longitude = longitude

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        if let placemark = placemarks?[0] {
                            
                            self.address = ""
                            
                            if placemark.name != nil {
                                self.address += placemark.name! + " "
                            }
                            
                            if placemark.subThoroughfare != nil {
                                self.address += placemark.subThoroughfare! + " "
                            }
                            
                            if placemark.thoroughfare != nil {
                                self.address += placemark.thoroughfare! + "\n"
                            }
                            
                            if placemark.subLocality != nil {
                                self.address += placemark.subLocality! + "\n"
                            }
                            
                            if placemark.subAdministrativeArea != nil {
                                self.address += placemark.subAdministrativeArea! + "\n"
//                                location = placemark.subAdministrativeArea!
                            }
                            
                            if placemark.postalCode != nil {
                                self.address += placemark.postalCode! + "\n"
                            }
                            
                            if placemark.country != nil {
                                self.address += placemark.country! + "\n"
                            }
                            
                            self.displayLocation(latitude: latitude, longitude:longitude, title: self.address)
                        }
                  }
            })
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
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesWhenAdded = true
            annotationView.markerTintColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
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

extension MapViewController: HandleMapSearch {
    func setSearchLocation(coordinate : CLLocationCoordinate2D,
                           title: String){
        citySelection = true
        getLocationAddressAndAddPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        self.displayLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, title: title)
        destination = coordinate
    }
}


extension MapViewController: UISearchBarDelegate {
    
}
