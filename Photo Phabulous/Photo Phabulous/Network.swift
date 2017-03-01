//
//  PicRetriever.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

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
                    var completeURLString : String? = "https://stachesandglasses.appspot.com/image/                    ahNzfnN0YWNoZXNhbmRnbGFzc2Vzch4LEgRVc2VyIg d0YWJpbmtzDAsSBVBob3RvGNOGAww/"
                    
                    //download picture
                    // ATTRIBUTION: https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
                    completeURLString = GalleryItem.userURLStringImageSuffix + tempImageURLString!
                    print("url: \(completeURLString)")
                    
                    
                    let tempGalleryItem = GalleryItem(date: tempDate!, caption: tempCaption!, imageURLString: completeURLString!)
                    
                    
                    guard let url = completeURLString,
                        let imageData = try? Data(contentsOf: URL(string: url)!) else {
                            break
                    }
                    
                    //only append to tempGalleryItems if image can be obtained
                    let imageToSet = UIImage(data: imageData)
                    
                    if (imageToSet != nil) {
                        tempGalleryItem.image = imageToSet
                        tempGalleryItemsArray.append(tempGalleryItem)
                    }
                    
                    
                    //If getting images asynchronously, call the getImageFromUrl method
//                    self.getImageFromURL(galleryItem: tempGalleryItem)
//                    tempGalleryItemsArray.append(tempGalleryItem)
  
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

    
    
    func uploadRequest(user: NSString, image: UIImage, caption: NSString){
        
        let boundary = generateBoundaryString()
        let scaledImage = resize(image: image, scale: 0.25)
        let imageJPEGData = UIImageJPEGRepresentation(scaledImage,0.1)
        
        guard let imageData = imageJPEGData else {return}
        
        // Create the URL, the user should be unique
        let url = NSURL(string: "http://stachesandglasses.appspot.com/post/\(user)/")
        
        // Create the request
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Set the type of the data being sent
        let mimetype = "image/jpeg"
        // This is not necessary
        let fileName = "test.png"
        
        // Create data for the body
        let body = NSMutableData()
        body.append("\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        
        // Caption data
        body.append("Content-Disposition:form-data; name=\"caption\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("CaptionText\r\n".data(using: String.Encoding.utf8)!)
        
        // Image data
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        // Trailing boundary
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        // Set the body in the request
        request.httpBody = body as Data
        
        // Create a data task
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            // Need more robust errory handling here
            // 200 response is successful post
            print(response!)
            print(error ?? "nil")
            
            // The data returned is the update JSON list of all the images
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString ?? "nil")
        }
        
        task.resume()
    }
    
    /// A unique string that signifies breaks in the posted data
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

    
    
    func resize(image: UIImage, scale: CGFloat) -> UIImage {
        let size = image.size.applying(CGAffineTransform(scaleX: scale,y: scale))
        let hasAlpha = true
        
        // Automatically use scale factor of main screen
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    
}

