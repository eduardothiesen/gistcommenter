//
//  Gist.swift
//  GistCommenter
//
//  Created by Eduardo Thiesen on 10/05/17.
//  Copyright © 2017 Eduardo Thiesen. All rights reserved.
//

import UIKit

class Gist: NSObject {

    var id: String!
    var gistDescription: String?
    var numberOfComments: Int!
    var numberOfForks: Int!
    var owner: String!
    var date: Date?
    
    init(id: String, gistDescription: String?, numberOfComments: Int, numberOfForks: Int, owner: String, date: Date?) {
        self.id = id
        self.gistDescription = gistDescription
        self.numberOfComments = numberOfComments
        self.numberOfForks = numberOfForks
        self.owner = owner
        self.date = date
    }
    
    init(dictionary: [String : Any]) {
        
    }
}
