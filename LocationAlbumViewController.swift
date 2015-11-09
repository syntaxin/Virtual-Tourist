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

class LocationAlbumViewController : UIViewController, MKMapViewDelegate  {
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
        
        
        let photos = fetchAllPictures()
        if photos.count == 0 {
            self.getPhotosFromFlickr(location)
            print("Got them now")
            let photos = fetchAllPictures()
            print(photos)
        } else {
            print("I have photos")
        }
        
        
    }
    
    // MARK: Core Data Capabilites
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func fetchAllPictures() -> [Photo] {
        //        let fetchRequest = NSFetchRequest()
        //
        //        fetchRequest.entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: sharedContext)
        //        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageName", ascending: true)]
        //        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location);
        //
        //        do {
        //            let results = try sharedContext.executeFetchRequest(fetchRequest)
        //            print([results])
        //            return results as! [Photo]
        //        } catch {
        //            print("nothing")
        //            return [Photo]()
        //
        //        }
        //TODO: Fetch Request for Photos
        return [Photo]()
    }
    
    
    //MARK: Use Location to Query Flickr
    func getPhotosFromFlickr (location: Location){
        
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
                            print(photo)
                            return photo

                    }
                    //CoreDataStackManager.sharedInstance().saveContext()
                } else {
                
                    print("still not working")
                }
            }
        }
    }
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


