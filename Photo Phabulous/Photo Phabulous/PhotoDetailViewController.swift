//
//  PhotoDetailViewController.swift
//  Photo Phabulous
//
//  Created by MouseHouseApp on 3/1/17.
//  Copyright © 2017 Umar Khokhar. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (image != nil ) {
            photoImageView.image = image
        } else {
            photoImageView.image = #imageLiteral(resourceName: "defaultImage")
        }
        
        
        // Resize if neccessary to ensure it's not pixelated
        if image.size.height <= photoImageView.bounds.size.height &&
            image.size.width <= photoImageView.bounds.size.width {
            photoImageView.contentMode = .center
        }

        // Do any additional setup after loading the view.
        
        self.navigationController?.hidesBarsOnTap = true
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(PhotoDetailViewController.userDidTapShare))
        
        self.navigationItem.rightBarButtonItem = shareBar
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ATTRIBUTION: http://www.appcoda.com/social-framework-introduction/
    func userDidTapShare() {
        let activityViewController = UIActivityViewController(activityItems: [self.image], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
