//
//  ImageDownloadManager.swift
//  LazyLoadingImage
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloadHandler = (_ image: UIImage?, _ url: URL, _ indexPath: IndexPath?, _ error: Error?) -> Void

final class ImageDownloadManager {
    private var completionHandler: ImageDownloadHandler?
    lazy var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.picsum.photos.imageDownloadqueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    let imageCache = NSCache<NSString, UIImage>()
    static let shared = ImageDownloadManager()
    private init () {}
    
    func downloadImage(_ picSumElement: PicSumPhotosModelElement, indexPath: IndexPath?, imageSize: Int, handler: @escaping ImageDownloadHandler) {
        self.completionHandler = handler
        guard let url = picSumElement.picSumPhotoImageURL(picSumElement.id!, size: imageSize) else {
            return
        }
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            /* check for the cached image for url, if YES then return the cached image */
            print("Return cached Image for \(url)")
           self.completionHandler?(cachedImage, url, indexPath, nil)
        } else {
             /* check if there is a download task that is currently downloading the same image. */
            if let operations = (imageDownloadQueue.operations as? [SSOperation])?.filter({$0.imageUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
                print("Increase the priority for \(url)")
                operation.queuePriority = .veryHigh
            }else {
                /* create a new task to download the image.  */
                print("Create a new task for \(url)")
                let operation = SSOperation(url: url, indexPath: indexPath)
                if indexPath == nil {
                    operation.queuePriority = .high
                }
                operation.downloadHandler = { (image, url, indexPath, error) in
                    if let newImage = image {
                        self.imageCache.setObject(newImage, forKey: url.absoluteString as NSString)
                    }
                    self.completionHandler?(image, url, indexPath, error)
                }
                imageDownloadQueue.addOperation(operation)
            }
        }
    }
    
    /* FUNCTION to reduce the priority of the network operation in case the user scrolls and an image is no longer visible. */
    func slowDownImageDownloadTaskfor (_ picSumElement: PicSumPhotosModelElement) {
        guard let url = picSumElement.picSumPhotoImageURL(picSumElement.id!, size: 200) else {
            return
        }
        if let operations = (imageDownloadQueue.operations as? [SSOperation])?.filter({$0.imageUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
            print("Reduce the priority for \(url)")
            operation.queuePriority = .low
        }
    }
    
    func cancelAll() {
        imageDownloadQueue.cancelAllOperations()
    }
    
}

