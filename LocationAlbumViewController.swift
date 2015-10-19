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

class LocationAlbumViewController : UIViewController, MKMapViewDelegate  {
//UICollectionViewDataSource, UICollectionViewDelegate
    
    var location: Location!
    
    @IBOutlet weak var locationMapView: MKMapView!
    //@IBOutlet weak var albumCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationMapView.delegate = self
        
        dispatch_async(dispatch_get_main_queue(), {
            self.locationMapView.addAnnotation(self.location)
        })
    }

// Implement the map
    
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//        
//        pinView?.canShowCallout = true
//        pinView?.pinTintColor = UIColor.redColor()
//        
//        return pinView
//    }
    
    
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

}
