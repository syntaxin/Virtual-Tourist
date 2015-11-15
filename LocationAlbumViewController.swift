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

class LocationAlbumViewController : UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate  {
    //UICollectionViewDataSource, UICollectionViewDelegate
    
    // MARK: Prepare view and get Core Data
    
    var location: Location!
    
    @IBOutlet weak var locationMapView: MKMapView!
    //@IBOutlet weak var albumCollection: UICollectionView!
    
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
                    
                    if let photosDictionary = photoResults.valueForKey("photos") as? [String:AnyObject],
                        let photosInDictionary = photosDictionary["photo"] as? [[String: AnyObject]]
                        
                    {
                        
                        _ = photosInDictionary.map() { (dictionary: [String: AnyObject]) -> Photo in
                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                            photo.location = self.location
                            return photo
                            
                        }
                        self.saveContext()
                    } else {
                        
                        print("Could not get photos from Flickr")
                    }
                }
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
}



//    //Implement the collection view
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //TODO: Get Count
//        let count = 0
//
//        return count
//    }
//
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//
//        let photo = collectionView.dequeueReusableCellWithReuseIdentifier("locationPhoto", forIndexPath: indexPath) as! LocationAlbumViewCell
//        //let meme = self.memeList[indexPath.row]
//        // Set the name and image
//        //cell.memeImageView.image = meme.memeImage
//
//        return photo
//    }
//
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
//    {
//        //TODO: Choose to delete
//    }

//
//            let resource = TheMovieDB.Resources.PersonIDMovieCredits
//            let parameters = [TheMovieDB.Keys.ID : actor.id]
//
//            TheMovieDB.sharedInstance().taskForResource(resource, parameters: parameters){ JSONResult, error  in
//                if let error = error {
//                    print(error)
//                } else {
//
//                    print(JSONResult)
//                    if let moviesDictionaries = JSONResult.valueForKey("cast") as? [[String : AnyObject]] {
//
//                        // Parse the array of movies dictionaries
//                        let _ = moviesDictionaries.map() { (dictionary: [String : AnyObject]) -> Movie in
//                            let movie = Movie(dictionary: dictionary, context: self.sharedContext)
//
//                            movie.actor = self.actor
//
//                            return movie
//                        }
//
//                        // Update the table on the main thread
//                        dispatch_async(dispatch_get_main_queue()) {
//                            self.tableView.reloadData()
//                        }
//
//                        // Save the context
//                        self.saveContext()
//
//                    } else {
//                        let error = NSError(domain: "Movie for Person Parsing. Cant find cast in \(JSONResult)", code: 0, userInfo: nil)
//                        print(error)
//                    }
//                }
//            }
