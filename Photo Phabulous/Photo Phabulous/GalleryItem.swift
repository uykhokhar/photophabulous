//
//  GalleryItem.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import Foundation
import UIKit

class GalleryItem {
    
    static let userURLString : String = "https://stachesandglasses.appspot.com/user/tabinks/json/"
    static let userURLStringImageSuffix : String = "https://stachesandglasses.appspot.com/"
    
    var date : String
    var caption: String
    var imageURLString: String
    var image : UIImage? 
    
    
    // ATTRIBUTION: http://swiftiostutorials.com/tutorial-using-uicollectionview-uicollectionviewflowlayout/ 
    init(date: String, caption: String, imageURLString: String) {
        self.date = date
        self.caption = caption
        self.imageURLString = imageURLString
    }
    
    func setImage(image: UIImage) {
        self.image = image
    }
    
    
}
