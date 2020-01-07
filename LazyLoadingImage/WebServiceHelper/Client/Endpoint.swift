//
//  Endpoint.swift
//  payzah_business
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import Foundation

/// Protocol for easy construction of URls, ideally an enum will be the one conforming to this protocol.
protocol Endpoint {
    
    var base:  String { get }
    var path: String { get }
}

extension Endpoint {
    
    var urlComponents: URLComponents? {
        guard var components = URLComponents(string: base) else { return nil }
        components.path.append(path)
        return components
    }
    
    //for get call
    var request: URLRequest? {
        
        guard let url = urlComponents?.url ?? URL(string: "\(self.base)\(self.path)") else { return nil }
        let request = URLRequest(url: url)
        print("URL Request :: ", request.url?.absoluteString ?? "")
        return request
    }
    
    //requestWithQuery
    func requestWithQuery(page: String) -> URLRequest? {
        var components = URLComponents()
        components = URLComponents(string: base)!
        components.path.append(path)
        
        let queryItemQuery = URLQueryItem(name: "page", value: page)
        components.queryItems = [queryItemQuery]
        
        guard let url = components.url ?? URL(string: "\(self.base)\(self.path)") else { return nil }
        let request = URLRequest(url: url)
        return request
    }
    
    //for post call
    func postRequest<T: Encodable>(parameters: T, headers: [HTTPHeader]) -> URLRequest? {
        
        guard var request = self.request else { return nil }
        request.httpMethod = HTTPMethods.post.rawValue
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
            
        } catch let error {
            print(APIError.postParametersEncodingFalure(description: "\(error)").customDescription)
            return nil
        }
        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
        print("URL Request :: ", request.url?.absoluteString ?? "")
        return request
    }
    
    func postRequestNoGenerics(parameters: [String: Any], headers: [HTTPHeader]) -> URLRequest? {
        
        guard var request = self.request else { return nil }
        request.httpMethod = HTTPMethods.post.rawValue
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
        } catch let error {
            print(APIError.postParametersEncodingFalure(description: "\(error)").customDescription)
            return nil
        }
        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
        print("URL Request :: ", request.url?.absoluteString ?? "")
        return request
    }
    
    //Refer link for post multiform call
    //for post multiform call
    //https://newfivefour.com/swift-form-data-multipart-upload-URLRequest.html
    /*
     Sample data
    //var r  = URLRequest(url: URL(string: "https://prospero.uatproxy.cdlis.co.uk/prospero/DocumentUpload.ajax")!)
    //    r.httpMethod = "POST"
    //    let boundary = "Boundary-\(UUID().uuidString)"
    //    r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    */
    
    func postMultiFormRequest(parameters: [String: String], headers: [HTTPHeader], boundary: String, dataArray: [[String: Any]] = [[:]], mimeType: String = "image/png") -> URLRequest? {
        
        guard var request = self.request else { return nil }
        request.httpMethod = HTTPMethods.post.rawValue
        
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        for dataItem in dataArray {
            if dataItem.count > 0 {
                let fileName = dataItem["fileName"] as! String
                let data = dataItem["data"] as! Data
                let key = dataItem["key"] as! String
                
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
                body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                body.append(data)
                body.appendString("\r\n")
            }
        }
        body.appendString("--".appending(boundary.appending("--")))
        
        request.httpBody = body as Data
        
        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
        print("URL Request :: ", request.url?.absoluteString ?? "")
        return request
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
