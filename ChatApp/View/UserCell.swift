//
//  UserCell.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit

class UserCell: BaseUserCell {
    
//    // MARK: - Properties
//    
//    let profileImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.layer.cornerRadius = 35
//        iv.layer.masksToBounds = true
//        iv.contentMode = .scaleAspectFill
//        return iv
//    }()
//    
//    // MARK: - Init
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        textLabel?.anchor(top: self.topAnchor, paddingTop: 10, left: profileImageView.rightAnchor, paddingLeft: 20, width: self.frame.width, height: 24)
//        textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        textLabel?.textColor = .white
//        
//        detailTextLabel?.anchor(top: textLabel!.bottomAnchor, paddingTop: 10, left: profileImageView.rightAnchor, paddingLeft: 20, width: self.frame.width, height: 24)
//        detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        detailTextLabel?.textColor = .white
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
//        backgroundColor = .clear
//        addSubview(profileImageView)
//        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        profileImageView.anchor(left: self.leftAnchor, paddingLeft: 10, width: 70, height: 70)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Set Components
    
    weak var user: Users? {
        didSet {
            textLabel?.text = user?.name
            detailTextLabel?.text = user?.email
            if let profileURL = user?.profilePhotoURL {
                let URL = NSURL(string: profileURL)
                profileImageView.sd_setImage(with: URL as URL?, completed: nil)
            }
        }
    }
}
