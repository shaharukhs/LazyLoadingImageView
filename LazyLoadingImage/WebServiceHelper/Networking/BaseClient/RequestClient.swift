//
//  RequestClient.swift
//  LazyLoadingImage
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import Foundation

class RequestClient: GenericAPIClient {
        
    internal let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
}

enum PicsumAPI {
    case list
    case id
}

extension PicsumAPI: Endpoint {
    var path: String {
        switch self {
        case .list: return "/v2/list"
        case .id: return "/id"
        }
    }
    
    var base: String {
        return "https://picsum.photos"
    }
}
