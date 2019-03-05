//
//  FirebaseUtils.swift
//  IgFirebase
//
//  Created by Derek on 2019/2/28.
//  Copyright © 2019 Derek. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUID(uid:String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String:Any] else {return}
            
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
        }) { (error) in
            print("Failed to fetch user for posts:", error)
        }
    }
}
