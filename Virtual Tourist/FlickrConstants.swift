//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation

extension FlickrClient {

    struct Constants {
    
        static let apiKey : String = "f6e4f4813a22a58539c4d0b55b9829c6"
        static let baseURL : String = "https://api.flickr.com/services/rest/"

        static let format = "json"
        static let latMin = -90.0
        static let latMax = 90.0
        static let longMin = -180.0
        static let longMax = 180.0
        static let photosPerPage = 30
        static let nojsoncallback = 1
        static let photoSize = "q"

        
    
    }
    
    struct Methods {
        static let photoSearch = "flickr.photos.search"
    
    }

    struct JSONResponseKeys {
        
        static let farmID = "farm"
        static let photoID = "id"
        static let secretID = "secret"
        static let serverID = "server"
        static let title = "title"
        static let urlString = "url_q"
        
    }
    
    struct imageURL {
        static let base = "https://farm"
        static let partTwo = ".staticflickr.com/"
        static let partThree = "/"
        static let defaultImage = "URL"
    }
}