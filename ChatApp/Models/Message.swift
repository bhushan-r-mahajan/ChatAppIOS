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
    var timestamp: Double?
    var imageURL: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func checkId() -> String? {
        return senderId == FirebaseAuth.Auth.auth().currentUser?.uid ? recieverId : senderId
    }
    
//    init(dictionary: [String: Any]) {
//        super.init()
//        recieverId = dictionary["recieverId"] as? String
//        senderId = dictionary["recieverId"] as? String
//        text = dictionary["recieverId"] as? String
//        timestamp = dictionary["recieverId"] as? Double
//        imageURL = dictionary["recieverId"] as? String
//        imageHeight = dictionary["recieverId"] as? NSNumber
//        imageWidth = dictionary["recieverId"] as? NSNumber
//    }
}
