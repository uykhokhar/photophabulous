//
//  PicRetriever.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import Foundation

class Networking {
    
    
    
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
                guard let issues = json as? [[String: AnyObject]] else {
                    fatalError("We couldn't cast the JSON to an array of dictionaries")
                }
                
                // Parse the array of dictionaries to get the important information that you
                // need to present to the user
                
                // Do some parsing here
                
                print("*****        BEGIN PARSING     ********")
                var tempIssuesArray : [GalleryItem] = []
                
                for entry in issues {
                    let url = entry["html_url"] as? String
                    let title = entry["title"] as? String
                    let userDic = entry["user"] as? [String: Any]
                    let user = userDic?["login"] as? String
                    let body = entry["body"] as? String
                    
                    let tempIssue = Issue(issueTitle: title!, gitUsername: user!, issueDate: date!, type: type, URL: url!, body: body!)
                    tempIssuesArray.append(tempIssue)
                }
                
                self.issuesArray = tempIssuesArray
                
                completion(self.issuesArray)
                
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        })
        
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }

    
    
}

