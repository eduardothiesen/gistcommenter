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
    
//        let gist = Gist()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDidReceiveGist"), object: nil, userInfo: nil)
    }
    
    override func processErrorData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        
        print(data)
        
        var userInfo: [String : Any] = [:]
        let title = "Ops, something went wrong"
        var description = ""
        
        if data["message"] as? String == "Bad credentials" {
            UserDefaults.standard.set(true, forKey: "receivedInvalidTokenNotification")
            
            KeychainWrapper.standard.set("", forKey: "token")
            userInfo["expired"] = true
        } else if data["message"] as? String == "Not Found" {
            description = "The Gist could not be found. Are you sure this is the right QR Code?"
        }
            //TODO: Map other erros for user friendly messages
        else {
            description = data["message"] as! String
        }
        
        userInfo["title"] = title
        userInfo["description"] = description
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDidReceiveGistError"), object: nil, userInfo: userInfo)
    }
}
