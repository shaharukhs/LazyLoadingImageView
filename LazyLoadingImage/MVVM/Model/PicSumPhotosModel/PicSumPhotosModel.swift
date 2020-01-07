//
//  PicSumPhotosModel.swift
//  LazyLoadingImage
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import Foundation

// MARK: - PicSumPhotosModelElement
struct PicSumPhotosModelElement: Codable {
    let id, author: String?
    let width, height: Int?
    let url, downloadURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
    
    func picSumPhotoImageURL(_ id: String, size: Int) -> URL? {
        if let url =  URL(string: "https://i.picsum.photos/id/" + id + "/\(size)/\(size).jpg") {
            return url
        }
        return nil
    }
}


typealias PicSumPhotosModel = [PicSumPhotosModelElement]
