//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import MapKit

class FlickrClient : coreRestAPI {

    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func getPhotosByLocation(location:Location, completionHandler: (photoProperties: [[String:String]]?, errorString: String?) -> Void) {
        
        let bBox = getBoundingBoxParams(location)
        
        let methodParams: [String:AnyObject] = [
            "method": FlickrClient.Methods.photoSearch,
            "bbox": bBox,
            "per_page": FlickrClient.Constants.photosPerPage,
            "api_key": FlickrClient.Constants.apiKey,
            "format": FlickrClient.Constants.format,
            "nojsoncallback": FlickrClient.Constants.nojsoncallback
        ]
        
        let url = Constants.baseURL + coreRestAPI.urlParameters(methodParams)
        
        coreRestAPI.httpGet(url) { result, NSError in
            
            if result == nil {
                    //completionHandler(photoProperties: nil, errorString: error?.localizedDescription)
            } else{
                    print(result)
            }
        
        }
    }
    
    func getBoundingBoxParams (location:Location) -> String {
        
        let bottom_left_lon = max(location.coordinate.longitude - FlickrClient.Constants.boundingBoxLongOffset, FlickrClient.Constants.longMin)
        let bottom_left_lat = max(location.coordinate.latitude - FlickrClient.Constants.boundingBoxLatOffset, FlickrClient.Constants.latMin)
        let top_right_lon = min(location.coordinate.longitude + FlickrClient.Constants.boundingBoxLongOffset, FlickrClient.Constants.longMax)
        let top_right_lat = min(location.coordinate.latitude + FlickrClient.Constants.boundingBoxLatOffset, FlickrClient.Constants.latMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    
}