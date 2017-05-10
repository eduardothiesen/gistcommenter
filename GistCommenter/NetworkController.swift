//
//  NetworkController.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 09/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class NetworkController: NSObject {
    
    let baseURL = "https://api.github.com/"
    
    static let shared = NetworkController()
    
    func login(username: String, password: String) {
        let authenticationRequest = AuthenticationRequest(url: baseURL + "authorizations", username: username, password: password)
        authenticationRequest.start()
    }
}
