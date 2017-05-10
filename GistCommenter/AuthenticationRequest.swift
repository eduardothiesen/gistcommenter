//
//  AuthenticationRequest.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class AuthenticationRequest: NetworkRequest {
    
    private static let clientId = "954063a3457af60766f5"
    private static let clientSecret = "645d8129912a09061a14134ae3d470c8c87da921"
    
    var url: String
    var username: String
    var password: String
    
    init(url: String, username: String, password: String) {
        self.url = url
        self.username = username
        self.password = password
    }
    
    override func start() {
        let auth = "\(username):\(password)".data(using: String.Encoding.utf8)
        let params = ["scopes" : ["gist"],
                      "client_id" : AuthenticationRequest.clientId,
                      "client_secret" : AuthenticationRequest.clientSecret] as [String : Any]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(auth!.base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        sessionTask = localURLSession?.dataTask(with: request)
        sessionTask?.resume()

    }
    
    override func processData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        print(data)
    }
    
    override func processErrorData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        print(data)
    }

}
