//
//  LocationAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class LocationAlbumViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate  {
    
    // MARK: Prepare view and get Core Data if it Exists
    
    var location: Location!
    
    var selectedIndexes = [NSIndexPath]()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        selectedIndexes = [NSIndexPath]()
        locationMapView.delegate = self
        
        self.addLocation()
        
        updateDeleteButton()

        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        collectionView.delegate = self

        
        fetchedResultsController.delegate = self
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if location.photos.isEmpty {
            getPhotosFromFlickr()
        }
    }
    
    //MARK: Delete actions
    @IBAction func deleteButtonClick(sender: AnyObject) {
    
        if selectedIndexes.count > 0 {
            deleteSelectedPhotos()
        } else {
            deleteAllPhotos()

        }
    
    }
    
    private func deleteSelectedPhotos(){
        
        var selectedPhotos = [Photo]()
        
        for indexPath in selectedIndexes {
            selectedPhotos.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in selectedPhotos {
            self.sharedContext.deleteObject(photo)
        }
        
        selectedIndexes = [NSIndexPath]()
        updateDeleteButton()
        
        self.saveContext()
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            getPhotosFromFlickr()
        }
        
    }
    
    private func deleteAllPhotos(){
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        
        self.saveContext()
        
        getPhotosFromFlickr()

    }
    
    //MARK: Get Photos from Flickr
    private func getPhotosFromFlickr (){
    
        FlickrClient.sharedInstance().getPhotosByLocation(location) { photoResults, errorString in
            
            if let error = errorString {
                
                print(error)
                
            } else {
                self.sharedContext.performBlockAndWait(
                    {
                        
                        if let photosDictionary = photoResults.valueForKey("photos") as? [String:AnyObject],
                            let photosInDictionary = photosDictionary["photo"] as? [[String: AnyObject]]
                            
                        {
                            
                            
                            _ = photosInDictionary.map() { (dictionary: [String: AnyObject]) -> Photo in
                                let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                photo.location = self.location
                                return photo
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView.reloadData()
                            }
                            
                            self.saveContext()
                        } else {
                            
                            print("Could not get photos from Flickr")
                        }
                    }
                )}
        }
    
    }
    
    
    // MARK: Core Data Capabilites
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageName", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Fetched Results Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            
            switch type {
            
            case .Insert:
                insertedIndexPaths.append(newIndexPath!)
                break
            case .Delete:
                deletedIndexPaths.append(indexPath!)
                break
            case .Update:
                updatedIndexPaths.append(indexPath!)
                break
            default:
                break
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
       
        collectionView.performBatchUpdates ({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    //MARK:Implement the Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let CellIdentifier = "locationPhotoCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! LocationAlbumViewCell
        
        configureCell(cell, photo: photo, indexPath: indexPath)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LocationAlbumViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            dispatch_async(dispatch_get_main_queue()){
            cell.locationPhotoView.alpha = 1.0
            }
        } else {
            selectedIndexes.append(indexPath)
            
            dispatch_async(dispatch_get_main_queue()){
            cell.locationPhotoView.alpha = 0.25
            }
        }
        
        updateDeleteButton()
        
    }
    
    func configureCell(cell: LocationAlbumViewCell, photo: Photo, indexPath: NSIndexPath) {
        
        var locationPhoto = UIImage(named: "photoPlaceholder")
        
        cell.locationPhotoView.image = nil
       
        if selectedIndexes.contains(indexPath) {
            cell.locationPhotoView.alpha = 0.25
        } else {
            cell.locationPhotoView.alpha = 1.0
        }
        
        if  photo.imageLink == "" {
            locationPhoto = UIImage(named: "noImage")
            
        } else if photo.image != nil {
            
            locationPhoto = photo.image
        }
            
        else {
            
            let task = FlickrClient.sharedInstance().taskForImage(photo.imageLink) {imageData, error in
                
                if let error = error {
                    print("Image download error: \(error.localizedDescription)")
                }
                
                if let data = imageData {
                    let photoImage = UIImage(data: data)
                    
                    photo.image = photoImage
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.locationPhotoView.image = photo.image
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.locationPhotoView.image = locationPhoto
    }
    
    //MARK: MKMapViewController
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        pinView?.canShowCallout = false
        pinView?.pinTintColor = UIColor.blueColor()

        
        return pinView
    }
    
    //Add Location on the MapView
    private func addLocation() {
        
        if let location = location {
            
            let span = MKCoordinateSpanMake(0.25,0.25)
            let region = MKCoordinateRegion(center:location.coordinate, span:span)
            
            locationMapView.region = region
            locationMapView.userInteractionEnabled = false
            locationMapView.addAnnotation(location)
            
            
        }
    
    }
    
    private func updateDeleteButton() {
        
        if selectedIndexes.count > 0 {
            self.deleteButton.setTitle( "Remove selected photos", forState: .Normal)
        } else {
            
            self.deleteButton.setTitle("Reset the photos", forState: .Normal)
        }
    }
}
