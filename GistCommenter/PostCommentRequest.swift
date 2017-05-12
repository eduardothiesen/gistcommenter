//
//  PostCommentRequest.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 11/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class PostCommentRequest: NetworkRequest {
    var url: String!
    var gistId: String!
    var body: String!
    
    init(url: String, gistId: String, body: String) {
        self.url = url
        self.gistId = gistId
        self.body = body
    }
    
    override func start() {
        url = url + gistId + "/comments?access_token=" + KeychainWrapper.standard.string(forKey: "token")!
        
        let params = ["body" : body] as [String : Any]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        sessionTask = localURLSession?.dataTask(with: request)
        sessionTask?.resume()
    }
    
    override func processData() {
        let data = try! JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments) as! [String : Any]
        
        let comment = Comment(dictionary: data)
        
        var userInfo: [String : Comment] = [:]
        userInfo["Comment"] = comment
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDidPostComment"), object: nil, userInfo: userInfo)
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDidReceiveCommentError"), object: nil, userInfo: userInfo)
    }

}
