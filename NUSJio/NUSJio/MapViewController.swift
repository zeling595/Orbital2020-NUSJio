//
//  MapViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/19.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
    func updateSaveButtonState()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    // the variable has controller-level scope to keep the UISearchController in memory after it is created
    var resultSearchController: UISearchController? = nil
    
    var selectedPin: MKPlacemark? = nil
    
    // need to configure save button, only show when user has selected a location

    override func viewDidLoad() {
        super.viewDidLoad()
        // It could take some time for requested information to come back, so delegate methods are used to handle responses asynchronously
        locationManager.delegate = self
        
        // could use something less accurate like kCLLocationAccuracyHundredMeters to conserve battery life
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // triggers the location permission dialog
        locationManager.requestWhenInUseAuthorization()
        
        // triggers a one-time location request
        locationManager.requestLocation()
        
        let locationSearchTableViewController = storyboard!.instantiateViewController(identifier: Constants.Storyboard.locationSearchTableViewController) as! LocationSearchTableViewController
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTableViewController)
        
        // The locationSearchTableViewController will also serve as the searchResultsUpdater delegate
        resultSearchController?.searchResultsUpdater = locationSearchTableViewController
        
        // configure the search bar and embed it in navigation bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        
        // configure the UISearchController appearance
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true // will not cover navigation controller
        
        locationSearchTableViewController.mapView = mapView
        
        // pass a handle of itself to the child controller
        locationSearchTableViewController.handleMapSearchDelegate = self
        
        updateSaveButtonState()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.saveUnwindToAddActivity {
            if let addActivityViewController = segue.destination as? AddActivityTableViewController,
                let selectedPin = selectedPin {
                let locationStr = "\(selectedPin.thoroughfare ?? ""), \(selectedPin.locality ?? ""), \(selectedPin.subLocality ?? ""), \(selectedPin.administrativeArea ?? ""), \(selectedPin.postalCode ?? ""), \(selectedPin.country ?? "")"
                addActivityViewController.chosenLocationLabel.text = locationStr
            }
        }
    }

}

extension MapViewController {
    
    // get called when user responds to the permission dialog
    // if allow, status becomes authorizeWhenInUse
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // trigger another request because the first attempt may suffer a permission failure
            locationManager.requestLocation()
        }
    }
    
    // his gets called when location information comes back. You get an array of locations, but you’re only interested in the first item.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location: \(location)")
            // span is an arbitrary area of 0.05 degrees longitude and latitude
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            // region consists of a centre and zoom level (span)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            // once you set the region, you can zoom
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
       
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // not suppose to be here but since this extension passed a reference...
    func updateSaveButtonState() {
          print("(print from map view)\(selectedPin == nil)")
          saveButton.isEnabled = !(selectedPin == nil)
      }
}
