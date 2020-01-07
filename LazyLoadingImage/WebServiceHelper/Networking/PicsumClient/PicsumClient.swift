//
//  PicsumClient.swift
//  LazyLoadingImage
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import Foundation
import UIKit

class PicsumClient: RequestClient {
    static let shared = PicsumClient()
    
    /// getCurrentLocationWeather
    func getPicSumPhotosList(page: String = "", withStatusCode statusCode: Int = 200, vc: UIViewController, completion: @escaping (Result<PicSumPhotosModel?, APIError>) -> ()) {
        if Reachability.isConnectedToNetwork() {
            guard let request = PicsumAPI.list.requestWithQuery(page: page) else { return }
            
            print("Request URL :: ", request.url?.absoluteString ?? "Some thing went wrong")
            self.fetch(with: request, withStatusCode: statusCode , decode: { json -> PicSumPhotosModel? in
                guard let results = json as? PicSumPhotosModel else { return  nil }
                return results
            }, completion: completion)
        } else {
            print("Not reachable")
            Alert.showNoInternetConnection(on: vc)
        }
    }
}
