//
//  coreRestAPI.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import Foundation
import UIKit

class coreRestAPI {

    
    /* Standardized Error Messages for the App */
    private struct ErrorMessage {
        static let domain = "Virtual Tourist"
        static let offline = "You need to be online"
        static let invalidURL = "Invalid URL"
        static let emptyURL = "Empty URL"
        static let jsonParseFailed = "Could not understand what Flickr told me"
    }
    
    
    class func httpGet(urlString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        if urlString != "" {
            if let url = NSURL(string: urlString) {
                
                let request = NSMutableURLRequest(URL: url)
                let session = NSURLSession.sharedSession()
                
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    
                    if error != nil {
                        completionHandler(result: nil, error: error)
                        return
                    }

                    self.parseJSONData(data!, completionHandler: completionHandler)
                
                }
                task.resume()
            } else {
                
                completionHandler(result: nil, error: NSError(domain: ErrorMessage.domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.invalidURL]))
            }
        } else {
            
            completionHandler(result: nil, error: NSError(domain: ErrorMessage.domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.emptyURL]))
        }
    }
    
    class func parseJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch {
            completionHandler(result: nil, error: NSError(domain: ErrorMessage.domain, code: 1, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.jsonParseFailed]))
        }
    }

    
    class func urlParameters (parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        let parameters = parameters
        
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}