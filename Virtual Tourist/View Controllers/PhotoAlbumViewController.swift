//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController{
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pin: Pin!
    var photoArray: [Photo] = []
    var dictionarySelectedIndexPath: [IndexPath : Bool] = [:]
    //var inEditMode = false
    var latString: String = ""
    var lonString: String = ""
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupCollectionView()
        loadImages()
        //updateButtonTitle()
    }
    
    private func setupMap() {
        mapView.addAnnotation(pin)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        setupFlowLayout()
    }
    
    private func setupFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func setupLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let centerX = label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerY = label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let heightAnchor = label.heightAnchor.constraint(equalToConstant: 50)
        view.addConstraints([centerX, centerY, heightAnchor])
        
        label.text = "No images to display"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26)
    }
    
    private func loadImages() {
        latString = String(pin.coordinate.latitude)
        lonString = String(pin.coordinate.longitude)
        loadingImages(true)
        FlickrClient.getImageIDs(lat: latString, lon: lonString, newCollection: false, completion: handleArrayOfPhoto(photoArray:))
    }
    
    private func handleArrayOfPhoto(photoArray: [Photo]) {
        if photoArray.count > 0 {
            self.photoArray = photoArray
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.loadingImages(false)
            }
        } else {
            DispatchQueue.main.async {
                self.loadingImages(false)
                self.button.isHidden = true
                self.setupLabel()
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        loadingImages(true)
        FlickrClient.getImageIDs(lat: latString, lon: lonString, newCollection: true, completion: handleArrayOfPhoto(photoArray:))
    }
    
    func loadingImages(_ loadingImages: Bool) {
        if loadingImages {
            activityIndicator.startAnimating()
            collectionView.allowsMultipleSelection = false
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
            button.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            collectionView.allowsMultipleSelection = true
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            button.isEnabled = true
        }
    }
    
    private func buildURL(_ index: Int) -> String{
        let id = photoArray[index].id
        let farmId = photoArray[index].farm
        let serverId = photoArray[index].server
        let secret = photoArray[index].secret
        let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
        return urlString
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "imagePlaceholder")
        
        let urlString = buildURL(indexPath.row)
        let url = URL(string: urlString)!
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            cell.imageView.image = imageFromCache
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    guard let data = data else {
                        self.photoArray.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            collectionView.reloadData()
                        }
                        return
                    }
                    let imageToCahce = UIImage(data: data)
                    DispatchQueue.main.async {
                        imageCache.setObject(imageToCahce!, forKey: urlString as AnyObject)
                        cell.imageView.image = imageToCahce
                    }
                }
                task.resume()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photoArray.remove(at: indexPath.row)
        collectionView.reloadData()

    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        let region = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: false)
    }
}
