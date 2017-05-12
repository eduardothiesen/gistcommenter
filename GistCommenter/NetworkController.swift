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
    
    func login(username: String, password: String, twoFactorId: String?) {
        let authenticationRequest = AuthenticationRequest(url: baseURL + "authorizations", username: username, password: password, twoFactorId: twoFactorId)
        authenticationRequest.start()
    }
    
    func retrieveGist(id: String) {
        let retrieveGistRequest = RetrieveGistRequest(url: baseURL + "gists/" + id)
        retrieveGistRequest.start()
    }
    
    func postComment(id: String, body: String) {
        let postCommentRequest = PostCommentRequest(url: baseURL + "gists/", gistId: id, body: body)
        postCommentRequest.start()
    }
}
