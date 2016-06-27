//
//  Post.swift
//  Makestagram
//
//  Created by Xiao Zheng on 6/27/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

// 1
class Post : PFObject, PFSubclassing {
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var image: UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    
    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    
    func uploadPost() {
        if let image = image {
            // Use the guard to extend the scope and deal with the code even when the variable does not exist.
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            // Use save in background to run the code asynconously.
            user = PFUser.currentUser() // any uploaded post should be associated with the current user
            self.imageFile = imageFile
            
            // Make sure the long running task do not get suspended after the app get closed: boilerplate code.
            // The API for background jobs makes us responsible for calling UIApplication.sharedApplication().endBackgroundTask 
            // as soon as our work is completed.
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            // Make the photo uploading code running in the background.
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                // 3
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
        }
    }
    
}