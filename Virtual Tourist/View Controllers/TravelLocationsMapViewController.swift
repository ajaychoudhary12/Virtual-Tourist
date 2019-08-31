//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, UIGestureRecognizerDelegate {

    var pinArray: [Pin] = []
    @IBOutlet weak var mapView: MKMapView!
    var pinAnnotationView: MKPinAnnotationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        createSampleAnnotations()
        setupMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(pinArray)
    }
    
    func createSampleAnnotations() {
        let pin = Pin(lat: 28.7014, long: 77.1025)
        let pin2 = Pin(lat: 12.9716, long: 77.5946)
        pinArray.append(pin)
        pinArray.append(pin2)
    }
    
    func setupMapView() {
        mapView.delegate = self
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureReconizer:)))
        gestureRecogniser.minimumPressDuration = 0.4
        mapView.addGestureRecognizer(gestureRecogniser)
        
        for pin in pinArray {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            let pin = Pin(lat: coordinate.latitude, long: coordinate.longitude)
            pinArray.append(pin)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func selectedPin(view: MKAnnotationView) -> Pin {
        var selectedPin: Pin!
        for pin in pinArray {
            if pin.lat == view.annotation?.coordinate.latitude && pin.long == view.annotation?.coordinate.longitude {
                selectedPin = pin
            }
        }
        return selectedPin
    }
    
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let albumVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        albumVC.pin = selectedPin(view: view)
        navigationController?.pushViewController(albumVC, animated: true)
    }
}
