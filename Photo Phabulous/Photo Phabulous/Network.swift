//
//  PicRetriever.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import Foundation
import UIKit

class SharedNetworking {
    
    //Singleton
    static let sharedInstance = SharedNetworking()
    private init() {}
    
    let urlImageSuffix = GalleryItem.userURLStringImageSuffix
    var tempImagesData : [GalleryItem] = []
    var tempImage : UIImage?
    
    
    
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
                guard let allResults = json as? [String: Any] else {
                    fatalError("We couldn't cast the JSON to an array of dictionaries")
                }
                
                // Parse the array of dictionaries to get the important information that you
                // need to present to the user
                
                // Do some parsing here
                
                var tempGalleryItemsArray : [GalleryItem] = []
                
                print("*****        BEGIN PARSING     ********")
                
                let jImages = allResults["results"] as? [[String: Any]]
                
                for entry in jImages! {
                    let tempDate = entry["date"] as? String
                    let tempCaption = entry["caption"] as? String
                    let tempImageURLString = entry["image_url"] as? String
                    
                    //download picture
                    // ATTRIBUTION: https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
                    let completeURLString = GalleryItem.userURLStringImageSuffix + tempImageURLString!
                    print("url: \(completeURLString)")
//                    let pictureURL = URL(string: completeURLString)!
//                    let imageData = try? Data(contentsOf: pictureURL as URL)
//                    let tempImage = UIImage(data: imageData!)
                    //TODO PROCESS IMAGE SO ONLY SMALL VERSION IS DOWNLOADED.
                    
                    
                    
                    let tempGalleryItem = GalleryItem(date: tempDate!, caption: tempCaption!, imageURLString: completeURLString)
                    self.getImageFromURL(galleryItem: tempGalleryItem)
                    
                    
                    
                    tempGalleryItemsArray.append(tempGalleryItem)
  
                }
                //is it after all the images have downloaded?
                print("DOWNLOAD TASK COMPLETED")
                self.tempImagesData = tempGalleryItemsArray
                
                completion(self.tempImagesData)
                
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        })
        
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }

    
    // ATTRIBUTION: http://stackoverflow.com/questions/39813497/swift-3-display-image-from-url
    //QUESTION: Since this is already on a differnet thread, no need to put code into completion block and download picture on a different thread?? which thread is this working on?
    
    func getImageFromURL(galleryItem: GalleryItem) {
        
        
        let pictureURL = URL(string: galleryItem.imageURLString)!
        
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: pictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        print(imageData)
                        let downloadedImage = UIImage(data: imageData)
                        galleryItem.image = downloadedImage
                        print("image set to tempImage")
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
    }
    
    
    
    
}

