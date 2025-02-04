//
//  Team.swift
//  protain
//
//  Created by 平田翔大 on 2021/02/10.
//

import Foundation
import Firebase

struct Team  {
    var teamId : String
    var teamName : String
    var invitedId : String
    var createdAt : Timestamp
    var teamImage : String
    

    
    init(dic: [String: Any]){
        self.teamId = dic["teamId"] as? String ?? ""
        self.teamName = dic["teamName"] as? String ?? ""
        self.invitedId = dic["招待した人のID"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.teamImage = dic["teamImage"] as? String ?? ""
    }
    
}
