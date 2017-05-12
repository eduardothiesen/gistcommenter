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
    var owner: String?
    var date: Date?
    
    init(id: String, gistDescription: String?, numberOfComments: Int, numberOfForks: Int, owner: String?, date: Date?) {
        self.id = id
        self.gistDescription = gistDescription
        self.numberOfComments = numberOfComments
        self.numberOfForks = numberOfForks
        self.owner = owner
        self.date = date
    }
    
    init(dictionary: [String : Any]) {
        self.id = dictionary["id"] as! String
        
        let ownerDic = dictionary["owner"] as? [String : Any]
        self.owner = ownerDic?["login"] as? String
        if self.owner == nil {
            self.owner = "Anonymous"
        }
        
        self.gistDescription = dictionary["description"] as? String
        if self.gistDescription == "" {
            self.gistDescription = "\t"
        }
        
        self.numberOfComments = dictionary["comments"] as! Int
        let forks: NSArray = dictionary["forks"] as! NSArray
        self.numberOfForks = forks.count
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let updated = dictionary["updated_at"] as? String {
            self.date = dateFormatter.date(from: updated)
        } else {
            self.date = dateFormatter.date(from: dictionary["created_at"] as! String)
        }        
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: self)
    }
}
