//
//  NearbyHelpViewController.swift
//  WG
//
//  Created by Nick Uzelac on 1/15/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class NearbyHelpViewController: UIViewController {
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.8523341, longitude: 151.2106085)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
    }
    
    // Add markers for the places nearby the device.
    func updateMarkers() {
        mapView.clear()
        
        
        
        // Get nearby places and add markers to the map.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        //let NE = CLLocationCoordinate2D(latitude: (mapView.myLocation?.coordinate.latitude)! + 5, longitude: (mapView.myLocation?.coordinate.longitude)! + 5)
        //let SW = CLLocationCoordinate2D(latitude: (mapView.myLocation?.coordinate.latitude)! - 5, longitude: (mapView.myLocation?.coordinate.longitude)! - 5)
        let NE = CLLocationCoordinate2D(latitude: 32.559778, longitude: -110.649968)
        let SW = CLLocationCoordinate2D(latitude: 32.017898, longitude: -111.371675)
        let bounds = GMSCoordinateBounds(coordinate: NE, coordinate: SW)
        placesClient.autocompleteQuery("hospital", bounds: bounds, filter: filter, callback: {(results, error) -> Void in
            if let error = error
            {
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            if let results = results {
                for result in results {
                    print("Result \(result.attributedFullText)")
                    self.placesClient.lookUpPlaceID(result.placeID!, callback: {(place, error) -> Void in
                        if let error = error {
                            print("Failed to look up: \(error.localizedDescription)")
                            return
                        }
                        
                        if let place = place {
                            print("Found \(place.name)")
                            let marker = GMSMarker(position: place.coordinate)
                            marker.title = place.name
                            marker.snippet = place.formattedAddress
                            marker.map = self.mapView
                        }
                    })
                }
            }
        })
    }
    
}

// Delegates to handle events for the location manager.
extension NearbyHelpViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        updateMarkers()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
