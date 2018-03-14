//
//  MatchModel.swift
//  Tindog
//
//  Created by Doyle on 13/03/18.
//  Copyright © 2018 Doyle. All rights reserved.
//

import Foundation
import Firebase

struct MatchModel {
    let uid: String
    let uid2: String
    let matchIsAcepted: Bool
    
    init?(snapshot: DataSnapshot){
        let uid = snapshot.key
        guard let dic = snapshot.value as? [String: Any],
            let uid2 = dic["uid2"] as? String,
            let matchIsAcepted = dic["matchIsAcepted"] as? Bool else{
                return nil
        }
        
        self.uid = uid
        self.uid2 = uid2
        self.matchIsAcepted = matchIsAcepted
    }
}
