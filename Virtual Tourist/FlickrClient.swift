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
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

    // MARK: Get Photos from Flickr by Location
    
    func getPhotosByLocation(location:Location, completionHandler: (photoResults: AnyObject!, errorString: String?) -> Void) {
        
        //let bBox = getBoundingBoxParams(location)
        
        let methodParams: [String:AnyObject] = [
            "method": FlickrClient.Methods.photoSearch,
            //"bbox": bBox,
            "per_page": FlickrClient.Constants.photosPerPage,
            "api_key": FlickrClient.Constants.apiKey,
            "format": FlickrClient.Constants.format,
            "nojsoncallback": FlickrClient.Constants.nojsoncallback,
            "extras": "url_q",
            "lat": location.latitude,
            "lon": location.longitude
        ]
        
        let url = Constants.baseURL + coreRestAPI.urlParameters(methodParams)
        
        coreRestAPI.httpGet(url) { result, NSError in
            
            if result == nil {
                completionHandler(photoResults: nil, errorString: NSError!.localizedDescription)
            } else {
                
                completionHandler(photoResults: result, errorString: nil)

                
            }
            
        }
    }
    
// MARK: Helper functions for Flickr
    
//    func getBoundingBoxParams (location:Location) -> String {
//        
//        let bottom_left_lon = max(location.coordinate.longitude - FlickrClient.Constants.boundingBoxLongOffset, FlickrClient.Constants.longMin)
//        let bottom_left_lat = max(location.coordinate.latitude - FlickrClient.Constants.boundingBoxLatOffset, FlickrClient.Constants.latMin)
//        let top_right_lon = min(location.coordinate.longitude + FlickrClient.Constants.boundingBoxLongOffset, FlickrClient.Constants.longMax)
//        let top_right_lat = min(location.coordinate.latitude + FlickrClient.Constants.boundingBoxLatOffset, FlickrClient.Constants.latMax)
//        
//        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
//    }
//    
    
    func taskForImage(imageLink: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: imageLink)
        //print(url)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageData: data, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    

    
    // MARK: - Shared Image Cache stoled from Favorite Actors
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}