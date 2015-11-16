//
//  SavedMapView.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 11/15/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import MapKit


private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("SavedMapView")

class SavedMapView: NSObject, NSCoding {

    var currentView: MKCoordinateRegion
        
    init(region: MKCoordinateRegion) {
        currentView = region
    }
    
    required init(coder aDecoder: NSCoder) {
        
        let latitude = aDecoder.decodeObjectForKey("latitude") as! CLLocationDegrees
        let longitude = aDecoder.decodeObjectForKey("longitude") as! CLLocationDegrees
        let latDelta = aDecoder.decodeObjectForKey("latDelta") as! CLLocationDegrees
        let lonDelta = aDecoder.decodeObjectForKey("lonDelta") as! CLLocationDegrees
        currentView = MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: MKCoordinateSpanMake(latDelta, lonDelta))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(currentView.center.latitude, forKey: "latitude")
        aCoder.encodeObject(currentView.center.longitude, forKey: "longitude")
        aCoder.encodeObject(currentView.span.latitudeDelta, forKey: "latDelta")
        aCoder.encodeObject(currentView.span.longitudeDelta, forKey: "lonDelta")
    }
   
    class func unarchivedInstance() -> SavedMapView? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? SavedMapView
        } else {
            return nil
        }
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
}