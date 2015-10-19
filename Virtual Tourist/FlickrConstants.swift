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
        static let boundingBoxLongOffset = 1.0
        static let boundingBoxLatOffset = 1.0
        static let latMin = -90.0
        static let latMax = 90.0
        static let longMin = -180.0
        static let longMax = 180.0
        static let photosPerPage = 24
        static let nojsoncallback = 1
        
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"

        
    
    }
    
    struct Methods {
        static let photoSearch = "flickr.photos.search"
    
    }


}