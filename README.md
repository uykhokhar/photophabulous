# mpcs51030-2017-winter-assignment-7-uykhokhar


ATTRIBUTIONS: 
Initial setup of collectionview: http://swiftiostutorials.com/tutorial-using-uicollectionview-uicollectionviewflowlayout/ 

Downloading a picture: https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started

Downloading a picture: http://stackoverflow.com/questions/39813497/swift-3-display-image-from-url

Social framework: http://www.appcoda.com/social-framework-introduction/

NSCache: https://www.hackingwithswift.com/example-code/system/how-to-cache-data-using-nscache


WHAT WORKS: 
Tapping on an image should present the image in full screen and present the opportunity to share on social media.

Network activity indicator. 

Users should be able to tap a “camera” icon to add a new picture to the feed.

Error Handling in the getDataFromURL function with custom Error type

11th point will be awarded to applications that make the navigation bar disappear on the ImageDetailViewController when the image is tapped



REFACTOR REQUIRED: 
Function call to update the collection view cell pictures is located in UI code. This should be located in networking code. I misinterpreted the direcions: "When showing an image in the collection view, first try to load the image from the cache, if it is not there retrieve it from the network. After successfully downloading the image, save it to NSCache so it will be available later." 

The initial view may not reload the images. Improvements to the code could not be tested due to quota limit. 
