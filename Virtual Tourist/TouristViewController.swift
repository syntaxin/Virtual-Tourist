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

    //MARK: Create needed elements and variables
    
    @IBOutlet weak var touristMapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var isEditMode = false
    var longPressGestureRecognizer: UILongPressGestureRecognizer!

    //MARK: Prepare view and get core data   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        touristMapView.delegate = self
        
        self.addLongPressGestureRecognizer()
        
        editButton.title = "Edit"
        editButton.enabled = false
        
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
    
    //MARK: Manage gesture recognizers
    
    func addLongPressGestureRecognizer(){
        longPressGestureRecognizer = UILongPressGestureRecognizer(target:self, action: "addLocation:")
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        longPressGestureRecognizer.delegate = self
        self.touristMapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func removeLongPressGestureRecognizer() {
        self.touristMapView.removeGestureRecognizer(longPressGestureRecognizer)
    }
    
    
    //MARK: Handle gestures and actions
    func addLocation (gestureReconizer: UILongPressGestureRecognizer){
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let touchLocation = gestureReconizer.locationInView(touristMapView)
        let touchCoordinate = touristMapView.convertPoint(touchLocation, toCoordinateFromView:touristMapView)
        let location = Location(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude, context: self.sharedContext)

        print(location.latitude)
        editButton.enabled = true
        CoreDataStackManager.sharedInstance().saveContext()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.touristMapView.addAnnotation(location)
        })
        
        
        //TODO: Get Photos Up front
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
            self.removeLongPressGestureRecognizer()
            dispatch_async(dispatch_get_main_queue(), {
            self.editButton.title = "Done"
            })
        } else {
            self.isEditMode = false
            self.addLongPressGestureRecognizer()
    
            let locations = fetchAllLocations()
            if locations.count > 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.editButton.title  = "Edit"
            })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.editButton.title  = "Edit"
                    self.editButton.enabled = false
                })
            
            }
            
            
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
        
        let location = view.annotation as! Location
        
        if isEditMode == true {
            deleteLocation(location)
        } else {
            dispatch_async(dispatch_get_main_queue(),{
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationAlbum") as! LocationAlbumViewController
                controller.location = location
                self.navigationController!.pushViewController(controller, animated: true)
            })
        }
    }
}

