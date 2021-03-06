//
//  PicCollectionViewController.swift
//  Photo Phabulous
//
//  Created by Umar Khokhar on 2/25/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PicCell"

class PicCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var galleryItems: [GalleryItem]? = []
    let cache = NSCache<NSString, UIImage>()
    let user = "ukhokhar"
    
    //push the image
    var selectedImage : UIImage? {
        willSet(image) {
            postData(image: image!)
        }
    }
    
    let userURL = GalleryItem.userURLString
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    
    // MARK: IBActions
    @IBAction func tapCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        // DO NOT CALL THIS UNLESS YOU HAVE NIB FILES
        //self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        
        
        reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    // Set the indexPath of the selected item as the sender for the segue
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        let photo = galleryItems?[indexPath.row]
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailStoryboard") as? PhotoDetailViewController
        if let viewController = viewController {
            viewController.image = photo?.image
            navigationController?.pushViewController(viewController, animated: true)
            
        }
    }
    
    
    
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.galleryItems!.count
    }

    
    // ATTRIBUTION: https://www.hackingwithswift.com/example-code/system/how-to-cache-data-using-nscache
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = UIColor.black
        cell.galleryItem = galleryItems?[indexPath.row]
        cell.indvImage.image = getImage(galleryItem: cell.galleryItem!)
        
        return cell
    }
    
    // Refresh screen and throw error if data could not be retrieved. 
    func reloadData(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        do {
            try SharedNetworking.sharedInstance.getDataFromURL(urlString: userURL) {(galleryItems) in
            
            DispatchQueue.main.async {
                // Anything in here is execute on the main thread
                // You should reload your table here.
                //tableView.reload()
                self.galleryItems = galleryItems
                print("COUNT OF GALLERY ITEMS: \(self.galleryItems?.count)")
                print("***DISPATCH QUEUE CALLED****")
                
                self.collectionView?.reloadData()
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
        } catch {
            let alert = UIAlertController(title: "Connection Error", message: "Could not retrieve data from server", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        

    }
    
    
    
    func postData(image: UIImage){
        SharedNetworking.sharedInstance.uploadRequest(user: user as NSString, image: image, caption: "testImage") { () in
            
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
        
    }
    
    func getImage(galleryItem: GalleryItem?) -> UIImage?{
        
        var returnImage : UIImage?
        
        
        // REFACTOR TO MAKE imageURLNSString MORE TYPE SAFE
        var imageURLNSString : NSString = ""
        if let imageURLString = galleryItem?.imageURLString {
            imageURLNSString = imageURLString as NSString
        }
        
        
        if let cachedVersion = cache.object(forKey: imageURLNSString) {
            // use the cached version
            returnImage = cachedVersion
        } else {
            // create it from scratch then store in the cache
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            SharedNetworking.sharedInstance.getImageFromURL(galleryItem: galleryItem!) {(newImage) in
                
                DispatchQueue.main.async {
                    
                    self.cache.setObject(newImage, forKey: imageURLNSString)
                    
                    returnImage = newImage
                    
                    //turn network activity off
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                }
            }
            
        }
        
        return returnImage
        
    }
    
    
    
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    // ATTRIBUTION: https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
    //1 size of cell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2 total padding space
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3 spacing between cells
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4 spacing between the lines 
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension PicCollectionViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = possibleImage
        } else {
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

