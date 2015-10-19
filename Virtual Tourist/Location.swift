//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Location : NSManagedObject, MKAnnotation {
    
    //managed variables
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //initializer
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext){

        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)
        
        //super class init
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        //set parameters, convert to NSNumbers to allow for an MSMangedObject
        self.latitude = NSNumber(double: latitude)
        self.longitude = NSNumber(double: longitude)

    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }
}