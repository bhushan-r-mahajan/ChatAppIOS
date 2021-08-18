//
//  Users.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import Foundation

class Users: NSObject {
    
    var email: String?
    var name: String?
    var profilePhotoURL: String?
    var id: String?
    
    init(dictionary: [String: Any]) {
        email = dictionary[StringConstants.email] as? String
        name = dictionary[StringConstants.name] as? String
        profilePhotoURL = dictionary[StringConstants.profilePhotoURL] as? String
        id = dictionary[StringConstants.id] as? String
    }
}
