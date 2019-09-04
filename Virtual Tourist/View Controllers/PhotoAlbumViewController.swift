//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pin: Pin!
    var photoArray: [Photo] = []
    var images: [PhotoEntity] = []
    var imagesArrayHasData = false
    var latString: String = ""
    var lonString: String = ""
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupCollectionView()
        setupFetchRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setupFetchRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? appDelegate.persistentContainer.viewContext.save()
    }
    
    private func setupFetchRequest() {
        let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        if let result = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) {
            images = result
            loadImages(newCollection: false)
        }
        
    }
    
    private func loadImages(newCollection: Bool) {
        if images.count == 0 {
            downloadImages(newCollection: newCollection)
        } else {
            imagesArrayHasData = true
            self.collectionView.reloadData()
        }
    }
    
    private func downloadImages(newCollection: Bool) {
        latString = String(pin.lat)
        lonString = String(pin.long)
        loadingImages(true)
        FlickrClient.getImageIDs(lat: latString, lon: lonString, newCollection: newCollection, completion: handleArrayOfPhoto(photoArray:))
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
        for image in images {
            appDelegate.persistentContainer.viewContext.delete(image)
            try? appDelegate.persistentContainer.viewContext.save()
        }
        imageCache.removeAllObjects()
        images = []
        photoArray = []
        imagesArrayHasData = false
        loadImages(newCollection: true)
    }
    
    func loadingImages(_ loadingImages: Bool) {
        if loadingImages {
            activityIndicator.startAnimating()
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
            button.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            button.isEnabled = true
        }
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imagesArrayHasData {
            return images.count
        } else {
            return photoArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "imagePlaceholder")
        collectionView.isUserInteractionEnabled = false
        if imagesArrayHasData == false {
            FlickrClient.getImages(photoArray: photoArray, index: indexPath.row) { (image, indexToDelete, isImageFromCache, urlString) in
                if let image = image {
                    if isImageFromCache == false {
                        let photoEntity = PhotoEntity(context: self.appDelegate.persistentContainer.viewContext)
                        photoEntity.image = image.pngData()
                        photoEntity.urlString = urlString
                        photoEntity.pin = self.pin
                        self.images.append(photoEntity)
                        if indexPath.row == self.photoArray.count - 1 {
                            self.imagesArrayHasData = true
                            collectionView.isUserInteractionEnabled = true
                        }
                        if indexPath.row == collectionView.visibleCells.count - 1 {
                            collectionView.isUserInteractionEnabled = true
                        }
                        try? self.appDelegate.persistentContainer.viewContext.save()
                    }
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
        } else {
            let imageData = images[indexPath.row].image
            cell.imageView.image = UIImage(data: imageData!)
            collectionView.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoArray.count > indexPath.row {
            photoArray.remove(at: indexPath.row)
        }
        imageCache.removeObject(forKey: images[indexPath.row].urlString as AnyObject)
        
        let imageToDelete = images[indexPath.row]
        appDelegate.persistentContainer.viewContext.delete(imageToDelete)
        try? appDelegate.persistentContainer.viewContext.save()
        images.remove(at: indexPath.row)
        if images.count == 0 {
            imagesArrayHasData = false
            loadImages(newCollection: false)
            return
        }
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
        let coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: false)
    }
}

extension PhotoAlbumViewController {

    private func setupMap() {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
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
        let bottomAnchor = label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let leadingAnchor = label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        let trailingAnchor = label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        let heightAnchor = label.heightAnchor.constraint(equalToConstant: 40)
        view.addConstraints([bottomAnchor, leadingAnchor, trailingAnchor, heightAnchor])
        
        label.text = "No images to display"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26)
    }
}
