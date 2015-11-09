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
    
    
    @NSManaged var imageName: String?
    @NSManaged var baseUrl: String?
    @NSManaged var imageLink: String?
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
        self.imageName = (dictionary[FlickrClient.JSONResponseKeys.photoID] as! String?)! + "_" + (dictionary[FlickrClient.JSONResponseKeys.secretID] as! String?)! + "_" + FlickrClient.Constants.photoSize + ".jpg"
        print(self.imageName)
        self.baseUrl = FlickrClient.imageURL.base + String(dictionary[FlickrClient.JSONResponseKeys.farmID]) + FlickrClient.imageURL.partTwo + (dictionary[FlickrClient.JSONResponseKeys.serverID] as! String?)! + "/"
         print(self.baseUrl)
        self.imageLink = self.baseUrl! + self.imageName!
         print(self.imageLink)

    }

    
    var image: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imageName)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageName!)
        }
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        image = nil
    }
}

