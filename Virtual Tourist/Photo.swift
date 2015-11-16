//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/19/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Photo: NSManagedObject {
    
    
    @NSManaged var imageName: String
    @NSManaged var baseUrl: String
    @NSManaged var imageLink: String
    @NSManaged var location: Location?


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
}

// initializer
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        // superclass init
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //set parameters of the photo object
        var farmString: String!
        
        if String(dictionary[FlickrClient.JSONResponseKeys.farmID]) != nil {
            farmString = String(dictionary[FlickrClient.JSONResponseKeys.farmID])
        } else
        
        {
            farmString = "1"
        }
        let serverString = dictionary[FlickrClient.JSONResponseKeys.serverID] as! String
        
        self.imageName = (dictionary[FlickrClient.JSONResponseKeys.photoID] as! String) + "_" + (dictionary[FlickrClient.JSONResponseKeys.secretID] as! String) + "_" + FlickrClient.Constants.photoSize + ".jpg"
        self.baseUrl = FlickrClient.imageURL.base + farmString + FlickrClient.imageURL.partTwo + serverString + "/"
        self.imageLink = (dictionary[FlickrClient.JSONResponseKeys.urlString] as! String)

    }

    
    var image: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imageName)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageName)
        }
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        image = nil
    }
}

