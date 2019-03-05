//
//  User.swift
//  IgFirebase
//
//  Created by Derek on 2019/2/28.
//  Copyright © 2019 Derek. All rights reserved.
//

import Foundation

struct User {
    
    let uid:String
    let username:String
    let profileImageUrl:String
    
    init(uid:String, dictionary:[String:Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
