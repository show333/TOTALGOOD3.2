//
//  Users.swift
//  TOTALGOOD
//
//  Created by 平田翔大 on 2021/12/20.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftMoment

class Users {
    
    var userId: String
    var userName: String
    var userImage: String
    var admin: Bool
    
    
    init(dic: [String: Any]) {
        self.userId = dic["userId"] as? String ?? ""
        self.userName = dic["userName"] as? String ?? ""
        self.userImage = dic["userImage"] as? String ?? ""
        self.admin = dic["admin"] as? Bool ?? false
    }
    
}