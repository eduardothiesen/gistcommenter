//
//  AuthenticationRequest.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class AuthenticationRequest: NetworkRequest {
    var url: String
    var username: String
    var password: String
    
    init(url: String, username: String, password: String) {
        self.url = url
        self.username = username
        self.password = password
    }
    
    override func start() {
        let params = String(format: "%@:%@", username, password)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(params.data(using: String.Encoding.utf8)!.base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        sessionTask = localURLSession?.dataTask(with: request)
        sessionTask?.resume()

    }
    
    override func processData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        print(data)
    }
    
    override func processErrorData() {
        
    }

}
