//
//  RetrieveGistRequest.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 10/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class RetrieveGistRequest: NetworkRequest {
    var url: String
    
    init(url: String) {
        self.url = url
    }
    
    override func start() {
        url = url + "?access_token=" + KeychainWrapper.standard.string(forKey: "token")!
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        sessionTask = localURLSession?.dataTask(with: request)
        sessionTask?.resume()
    }
    
    override func processData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        
        print(data)
        
        KeychainWrapper.standard.set(data["token"] as! String, forKey: "token")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDidAuthenticateUser"), object: nil)
    }
    
    override func processErrorData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        
        print(data)
        
        var userInfo: [String : Any] = [:]
        let title = "Ops, something went wrong"
        var description = ""
        
        if data["message"] as? String == "Bad credentials" {
            description = "Your access token expired"
        }
            //TODO: Map other erros for user friendly messages
        else {
            description = data["message"] as! String
        }
        
        userInfo["title"] = title
        userInfo["description"] = description
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDidReceiveLoginError"), object: nil, userInfo: userInfo)
    }
}
