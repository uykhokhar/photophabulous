//
//  PicRetriever.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import Foundation

class Network {
    
    //Singleton
    static let sharedInstance = Network()
    private init() {}
    
    
    var tempImages : [GalleryItem] = []
    
    
    
    func getDataFromURL(urlString: String, completion: @escaping ([GalleryItem]) -> Void){
        
        
        guard let url = NSURL(string: urlString) else {
            fatalError("Unable to create NSURL from string")
        }
        
        // Create a vanilla url session
        let session = URLSession.shared
        
        // Create a data task
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
            // Print out the response
            print("Response: \(response)")
            
            // Ensure there were no errors returned from the request
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                fatalError("Error: \(error!.localizedDescription)")
            }
            
            // Ensure there is data and unwrap it
            guard let data = data else {
                fatalError("Data is nil")
            }
            
            // We received data but it needs to be processed
            print("Raw data: \(data)")
            
            // Serialize the raw data into JSON using `NSJSONSerialization`.  The "do-try" is
            // part of an error handling feature of Swift that will be disccused in the future.
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(json)
                
                // Cast JSON as an array of dictionaries
                guard let allResults = json as? [String: AnyObject] else {
                    fatalError("We couldn't cast the JSON to an array of dictionaries")
                }
                
                // Parse the array of dictionaries to get the important information that you
                // need to present to the user
                
                // Do some parsing here
                
                let jImages = allResults["results"] as? [String: AnyObject]
                
                for entry in jImages! {
                    let tempDate = entry["date"] as? String
                    let tempCaption = entry["caption"] as? String
                    let tempImageURLString = entry["image_url"] as? String
                    
                    let tempImage = GalleryItem(date: tempDate!, caption: tempCaption!, imageURLString: tempImageURLString!)
                    tempImagesArray.append(tempImage)
                }
                
                
                
                print("*****        BEGIN PARSING     ********")
                var tempImagesArray : [GalleryItem] = []
                
                
                
                
                
                self.tempImages = tempImagesArray
                
                completion(self.tempImages)
                
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        })
        
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }

    
    
}

