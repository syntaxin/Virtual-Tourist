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
    
    // MARK: Prepare view and get Core Data
    
    var location: Location!
    
    var selectedIndexes = [NSIndexPath]()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationMapView.delegate = self
        
        dispatch_async(dispatch_get_main_queue(), {
            self.locationMapView.addAnnotation(self.location)
        })
        
        
        // Step 2: Perform the fetch
        
        do {
            try fetchedResultsController.performFetch()
            print (location.photos.count)
        } catch {}
        collectionView.delegate = self

        
        // Step 6: Set the delegate to this view controller
        // Set the view controller as the delegate
        
        fetchedResultsController.delegate = self
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if location.photos.isEmpty {
            
            FlickrClient.sharedInstance().getPhotosByLocation(location) { photoResults, errorString in
                
                if let error = errorString {
                    
                    print(error)
                    
                } else {
                    self.sharedContext.performBlockAndWait(
                        {
                            
                            if let photosDictionary = photoResults.valueForKey("photos") as? [String:AnyObject],
                                let photosInDictionary = photosDictionary["photo"] as? [[String: AnyObject]]
                                
                            {
                                
                                
                                //print(photosDictionary)
                                _ = photosInDictionary.map() { (dictionary: [String: AnyObject]) -> Photo in
                                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                    photo.location = self.location
                                    return photo
                                    
                                }
                                
                                //Update the table on the main thread
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
    
    //MARK:Implement the Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let CellIdentifier = "locationPhotoCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! LocationAlbumViewCell
        
        configureCell(cell, photo: photo)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! LocationAlbumViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.locationPhotoView.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            cell.locationPhotoView.alpha = 0.5
        }
        
    }
    
    func configureCell(cell: LocationAlbumViewCell, photo: Photo) {
        
        var locationPhoto = UIImage(named: "photoPlaceholder")
        
        cell.locationPhotoView.image = nil
        
        //Set the Location Photo Image
        
        if  photo.imageLink == "" {
            locationPhoto = UIImage(named: "noImage")
            
        } else if photo.image != nil {
            
            locationPhoto = photo.image
        }
            
        else {
            
            // Start the task that will eventually download the image
            let task = FlickrClient.sharedInstance().taskForImage(photo.imageLink) {imageData, error in
                
                if let error = error {
                    print("Image download error: \(error.localizedDescription)")
                }
                
                if let data = imageData {
                    // Create the image
                    let photoImage = UIImage(data: data)
                    
                    // update the model, so that the infrmation gets cashed
                    photo.image = photoImage
                    //print(photo.imageLink)
                    
                    // update the cell later, on the main thread
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.locationPhotoView.image = photo.image
                    }
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.locationPhotoView.image = locationPhoto
    }
    
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

}
