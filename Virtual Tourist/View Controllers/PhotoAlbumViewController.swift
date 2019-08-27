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
    var images: [UIImage] = []
    var dictionarySelectedIndexPath: [IndexPath : Bool] = [:]
    var inEditMode = false
    var latString: String = ""
    var lonString: String = ""
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupCollectionView()
        loadImages()
        updateButtonTitle()
    }
    
    private func setupMap() {
        mapView.addAnnotation(pin)
        mapView.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        setupFlowLayout()
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
        if images.count == 0 {
            latString = String(pin.coordinate.latitude)
            lonString = String(pin.coordinate.longitude)
            loadingImages(true)
            FlickrClient.getImageIDs(lat: latString, lon: lonString, newCollection: false, completion: handleArrayOfPhoto(photoArray:))
        }
    }
    
    private func setupFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func handleArrayOfPhoto(photoArray: [Photo]) {
        if photoArray.count > 0 {
            FlickrClient.requestImageFile(photoArray: photoArray, completion: handleImageFile(images:))
        } else {
            DispatchQueue.main.async {
                self.setupLabel()
            }
        }
    }
    
    private func handleImageFile(images: [UIImage]) {
        self.images = images
        DispatchQueue.main.async {
            self.collectionView.reloadData {
                self.loadingImages(false)
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if inEditMode {
            var deleteNeededIndexdPaths: [IndexPath] = []
            for (key, value) in dictionarySelectedIndexPath {
                if value {
                    deleteNeededIndexdPaths.append(key)
                }
            }
            for i in deleteNeededIndexdPaths.sorted(by: { $0.item > $1.item}) {
                images.remove(at: i.item)
            }
            collectionView.deleteItems(at: deleteNeededIndexdPaths)
            dictionarySelectedIndexPath.removeAll()
            inEditMode = false
            updateButtonTitle()
        } else {
            loadingImages(true)
            FlickrClient.getImageIDs(lat: latString, lon: lonString, newCollection: true, completion: handleArrayOfPhoto(photoArray:))
            if self.images.count != 0 {
                label.isHidden = true
            }
        }
    }
    
    private func updateButtonTitle() {
        if inEditMode {
            button.setTitle("DELETE", for: .normal)
        } else {
            button.setTitle("NEW COLLECTION", for: .normal)
        }
    }
    
    private func deselectAllItems(animated: Bool) {
        let selectedItems = collectionView.indexPathsForVisibleItems
        for indexPath in selectedItems {
            collectionView.deselectItem(at: indexPath, animated: animated)
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.imageView.alpha = 1
        }
    }
    
    func loadingImages(_ loadingImages: Bool) {
        if loadingImages {
            activityIndicator.startAnimating()
            button.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            button.isEnabled = true
        }
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "imagePlaceholder")
        DispatchQueue.main.async {
            if self.images.count <= indexPath.row {
         
            } else {
                print("images.count: \(self.images.count)")
                print("indexPath.row: \(indexPath.row)")
                cell.imageView.image = self.images[indexPath.row]
                cell.setNeedsLayout()
                self.deselectAllItems(animated: true)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.imageView.alpha = 0.5
        dictionarySelectedIndexPath[indexPath] = true
        if collectionView.indexPathsForSelectedItems?.count == 1 {
            inEditMode = true
            updateButtonTitle()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.imageView.alpha = 1
            dictionarySelectedIndexPath[indexPath] = false
        if collectionView.indexPathsForSelectedItems == [] {
            inEditMode = false
            updateButtonTitle()
        }
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

extension UICollectionView {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
}

