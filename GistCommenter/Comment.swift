//
//  Comment.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 11/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var avatar: String?
    var body: String?
    
    init(avatar: String?, body: String?) {
        self.avatar = avatar
        self.body = body
    }
    
    init(dictionary: [String : Any]) {
        let userDic = dictionary["user"] as? [String : Any]
        self.avatar = userDic?["avatar_url"] as? String
        self.body = dictionary["body"] as? String
    }
}
