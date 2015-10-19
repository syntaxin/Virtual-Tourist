//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import MapKit

class FlickrClient: coreRestAPI {

    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func getPhotosByLocation(latitude: Double, longitude: Double, completionHandler: (photoProperties: [[String:String]]?, errorString: String?) -> Void) {
        
        let bBox = getBoundingBoxParams(latitude, longitude: longitude)
        
        let methodParams: [String:AnyObject] = [
            "method": FlickrClient.Methods.photoSearch,
            "bbox": bBox,
            "per_page": FlickrClient.Constants.photosPerPage
        ]
        
        let url = Constants.baseURL + coreRestAPI.urlParameters(methodParams)
        
        print(url)
        
        //FlickrClient.sharedInstance().getPhotosByLocation(latitude, longitude: longitude)
    }
    
    
    func getBoundingBoxParams (latitude: Double, longitude: Double) -> String {
        
        let bottom_left_lon = max(longitude - FlickrClient.Constants.boundingBoxLongOffset, FlickrClient.Constants.longMin)
        let bottom_left_lat = max(latitude - FlickrClient.Constants.boundingBoxLatOffset, FlickrClient.Constants.latMin)
        let top_right_lon = min(longitude + FlickrClient.Constants.boundingBoxLongOffset, FlickrClient.Constants.longMax)
        let top_right_lat = min(latitude + FlickrClient.Constants.boundingBoxLatOffset, FlickrClient.Constants.latMax)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    
}