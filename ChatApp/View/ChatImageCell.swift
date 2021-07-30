//
//  ChatImageCell.swift
//  ChatApp
//
//  Created by Gadgetzone on 30/07/21.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ChatImageCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let reuseIdentifier = "cellID"
    
    let messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomInImageWhenTapped)))
        return iv
    }()
    
    var messageImageViewRightAnchor: NSLayoutConstraint!
    var messageImageViewLeftAnchor: NSLayoutConstraint!
    
    var message: Message? {
        didSet {
            setupMessageCell()
        }
    }
    
    //MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        configureComponents()
    }
    
    //MARK: - Configure Functions
    
    func configureComponents() {
        addSubview(messageImageView)
        messageImageView.anchor(top: topAnchor, paddingTop: 16, bottom: bottomAnchor, paddingBottom: 16)
        messageImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        messageImageViewLeftAnchor = messageImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
        messageImageViewLeftAnchor.isActive = false
        messageImageViewRightAnchor = messageImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        messageImageViewRightAnchor.isActive = false
    }
    
    func setupMessageCell() {
        guard let message = message else { return }
        guard let imageURL = message.imageURL else { return }
        let URL = NSURL(string: imageURL)
        messageImageView.sd_setImage(with: URL as URL?, completed: nil)
        
        if message.senderId == FirebaseAuth.Auth.auth().currentUser?.uid {
            messageImageViewLeftAnchor.isActive = false
            messageImageViewRightAnchor.isActive = true
        } else {
            messageImageViewRightAnchor.isActive = false
            messageImageViewLeftAnchor.isActive = true
        }
    }
    
    //MARK: - Objc Functions
    
    @objc func zoomInImageWhenTapped(tapgesture: UITapGestureRecognizer) {
        print("Image tapped")
    }
}
