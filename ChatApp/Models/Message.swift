//
//  Message.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var recieverId: String?
    var senderId: String?
    var text: String?
    var timestamp: String?
    var imageURL: String?
    var message: String?
    
    func checkId() -> String? {
        return senderId == FirebaseAuth.Auth.auth().currentUser?.uid ? recieverId : senderId
    }
    
    init(dictionary: [String: Any]) {
        recieverId = dictionary[StringConstants.recieverId] as? String
        senderId = dictionary[StringConstants.senderId] as? String
        text = dictionary[StringConstants.text] as? String
        timestamp = dictionary[StringConstants.timestamp] as? String
        imageURL = dictionary[StringConstants.imageURL] as? String
        message = dictionary["message"] as? String
    }
}
