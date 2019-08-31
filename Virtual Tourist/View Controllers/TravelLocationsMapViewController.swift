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
    
    func createSampleAnnotations() {
        let coordinate = CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025)
        let pin = Pin(coordinate: coordinate)
        pinArray.append(pin)
        let coordinate2 = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
        let pin2 = Pin(coordinate: coordinate2)
        pinArray.append(pin2)
    }
    
    func setupMapView() {
        mapView.delegate = self
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureReconizer:)))
        gestureRecogniser.minimumPressDuration = 0.4
        mapView.addGestureRecognizer(gestureRecogniser)
        mapView.addAnnotations(pinArray)
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let pin = Pin(coordinate: coordinate)
            pinArray.append(pin)
            mapView.addAnnotation(pin)
        }
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
        let pin = view.annotation as? Pin
        albumVC.pin = pin
        navigationController?.pushViewController(albumVC, animated: true)
    }
}
