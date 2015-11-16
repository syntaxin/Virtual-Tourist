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
        
        var page = 1
        var methodParams: [String:AnyObject]!
        
        dispatch_async(dispatch_get_main_queue()){
        
            self.getRandomPage(location) { result, errorString in
            
            if result == nil {
                
                methodParams = [
                    "method": FlickrClient.Methods.photoSearch,
                    "per_page": FlickrClient.Constants.photosPerPage,
                    "api_key": FlickrClient.Constants.apiKey,
                    "format": FlickrClient.Constants.format,
                    "nojsoncallback": FlickrClient.Constants.nojsoncallback,
                    "extras": "url_q",
                    "lat": location.latitude,
                    "lon": location.longitude,
                    "page": page
                ]
                
                let url = Constants.baseURL + coreRestAPI.urlParameters(methodParams)
                coreRestAPI.httpGet(url) { result, NSError in
                    
                    if result == nil {
                        completionHandler(photoResults: nil, errorString: NSError!.localizedDescription)
                    } else {
                        
                        completionHandler(photoResults: result, errorString: nil)
                        
                        
                    }
                    
                }
                
            } else {
                
                page = result
                
                methodParams = [
                    "method": FlickrClient.Methods.photoSearch,
                    "per_page": FlickrClient.Constants.photosPerPage,
                    "api_key": FlickrClient.Constants.apiKey,
                    "format": FlickrClient.Constants.format,
                    "nojsoncallback": FlickrClient.Constants.nojsoncallback,
                    "extras": "url_q",
                    "lat": location.latitude,
                    "lon": location.longitude,
                    "page": page
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
            
        }
        }
    }
    
    
    
    func taskForImage(imageLink: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: imageLink)
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
    
    func getRandomPage(location:Location ,completionHandler:(result:Int!,errorString: String?) ->Void){
        
        let methodParams: [String:AnyObject] = [
            "method": FlickrClient.Methods.photoSearch,
            "per_page": FlickrClient.Constants.photosPerPage,
            "api_key": FlickrClient.Constants.apiKey,
            "format": FlickrClient.Constants.format,
            "nojsoncallback": FlickrClient.Constants.nojsoncallback,
            "extras": "url_q",
            "lat": location.latitude,
            "lon": location.longitude
        ]
        
        let url = Constants.baseURL + coreRestAPI.urlParameters(methodParams)
        var page = 1
        coreRestAPI.httpGet(url) { result, NSError in
            
            if result == nil {
                
                completionHandler(result: page, errorString: "Could not get a random page")
            
            } else {
            
                if let searchResults = result.valueForKey("photos") as? [String:AnyObject],
                    let pageCount = searchResults["pages"] as? Int {
                        
                        if pageCount > 1 {
                            page = Int (arc4random_uniform(UInt32(pageCount))) + 1
                            completionHandler(result: page, errorString: nil)
                        } else {
                            completionHandler(result: page, errorString: nil)
                        }
                       
                }
                
            }
            
        }

    }
    
    // MARK: - Shared Image Cache stoled from Favorite Actors
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}