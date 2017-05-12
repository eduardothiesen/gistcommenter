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
    var twoFactorId: String?
    
    init(url: String, username: String, password: String, twoFactorId: String?) {
        self.url = url
        self.username = username
        self.password = password
        self.twoFactorId = twoFactorId
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
        
        if let twoFactor = self.twoFactorId {
            request.addValue(twoFactor, forHTTPHeaderField: "X-GitHub-OTP")
        }
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
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
            description = "The username or password are incorrect. Please, try again."
        } else if data["message"] as? String == "Must specify two-factor authentication OTP code." {
            userInfo["two-factor"] = true
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
