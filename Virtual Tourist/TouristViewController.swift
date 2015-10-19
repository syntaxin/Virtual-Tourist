//
//  TouristViewController.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/11/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TouristViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {

    @IBOutlet weak var touristMapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var isEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        touristMapView.delegate = self
        self.addLongPressGestureRecognizer()
        editButton.title = "Edit"
        editButton.enabled = false
        
        // CoreData
        let locations = fetchAllLocations()
        if !locations.isEmpty {
            
            dispatch_async(dispatch_get_main_queue(), {
            for location in locations {
                    self.touristMapView.addAnnotation(location)
                }
            })
            
            editButton.enabled = true
            
        }
    }
    
    
    //MARK: CoreData Capabilities

    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func fetchAllLocations() -> [Location] {
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: sharedContext)
        
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            return results as! [Location]
        } catch {
            return [Location]()
        }
    }
    
    //MARK: Create gesture recognizers and behaviors
    
    func addLongPressGestureRecognizer(){
        let lgpr = UILongPressGestureRecognizer(target:self, action: "handleLongPress:")
        lgpr.minimumPressDuration = 0.5
        lgpr.delaysTouchesBegan = true
        lgpr.delegate = self
        self.touristMapView.addGestureRecognizer(lgpr)
    }
    
    //Handle the Long Press once identified
    func handleLongPress (gestureReconizer: UILongPressGestureRecognizer){
        
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let touchLocation = gestureReconizer.locationInView(touristMapView)
        let touchCoordinate = touristMapView.convertPoint(touchLocation, toCoordinateFromView:touristMapView)
        
        let location = Location(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude, context: self.sharedContext)
        
        print(location.latitude)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.touristMapView.addAnnotation(location)
        })
    }
    
    func deleteLocation(location: Location) {
        touristMapView.removeAnnotation(location)
        sharedContext.deleteObject(location)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
// MARK: Manage the Editing of Locations
    

    
    @IBAction func editLocations (sender: AnyObject) {
        //print(isEditMode.boolValue)
        if isEditMode == false {
            self.isEditMode = true
            
            dispatch_async(dispatch_get_main_queue(), {
            self.editButton.title = "Done"
            })
        } else {
            
            self.isEditMode = false
            dispatch_async(dispatch_get_main_queue(), {
            self.editButton.title  = "Edit"
            })
        }
        
    }

//MARK: Implement the Map view
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        pinView?.canShowCallout = false
        pinView?.pinTintColor = UIColor.redColor()
        
        return pinView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        //TODO: Go to Album View

    }
}

