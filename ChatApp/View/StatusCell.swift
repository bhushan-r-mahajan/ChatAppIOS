//
//  StatusCell.swift
//  ChatApp
//
//  Created by Gadgetzone on 07/08/21.
//

import UIKit
import FirebaseAuth

class StatusCell: BaseUserCell {
    
    weak var user: Users? {
        didSet {
            let currentUser = FirebaseAuth.Auth.auth().currentUser?.uid
            if currentUser == user?.id {
                textLabel?.text = "My Status"
                detailTextLabel?.text = "Status"
            } else {
                textLabel?.text = user?.name
                detailTextLabel?.text = "Status"
            }
            if let profileURL = user?.profilePhotoURL {
                let URL = NSURL(string: profileURL)
                profileImageView.sd_setImage(with: URL as URL?, completed: nil)
            }
        }
    }
}
