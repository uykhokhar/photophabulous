//
//  GalleryItem.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import Foundation

class GalleryItem {

    var date : String
    var caption: String
    var imageURLString: String
    
    
    // ATTRIBUTION: http://swiftiostutorials.com/tutorial-using-uicollectionview-uicollectionviewflowlayout/ 
    init(date: String, caption: String, imageURLString: String) {
        self.date = date
        self.caption = caption
        self.imageURLString = imageURLString
    }
    
    
}
