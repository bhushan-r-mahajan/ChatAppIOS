//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Gadgetzone on 26/07/21.
//

import UIKit
import FirebaseAuth

class ChatMessageCell: UITableViewCell {
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.backgroundColor = .clear
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let bubbleView: UIView  = {
        let bubble = UIView()
        bubble.backgroundColor = .link
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.layer.cornerRadius = 10
        return bubble
    }()
    
    let messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.backgroundColor = .brown
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    var messageLeftConstraint: NSLayoutConstraint!
    var messageRightConstraint: NSLayoutConstraint!
    var messageImageTopConstraint: NSLayoutConstraint!
    var messageImageBottomConstraint: NSLayoutConstraint!
    var messageImageLeftConstraint: NSLayoutConstraint!
    var messageImageRightConstraint: NSLayoutConstraint!
    var messageImageHeightConstraint: NSLayoutConstraint!
    var bubbleViewHeightConstraint: NSLayoutConstraint!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        configureComponents()
    }
    
    func configureComponents() {
        addSubview(bubbleView)
        bubbleView.anchor(top: topAnchor, paddingTop: 16, bottom: bottomAnchor, paddingBottom: 16)
        bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        bubbleViewHeightConstraint = bubbleView.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        bubbleViewHeightConstraint.isActive = false
        
        messageLeftConstraint = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16)
        messageLeftConstraint.isActive = false
        messageRightConstraint = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        messageRightConstraint.isActive = false
        
        bubbleView.addSubview(messageLabel)
        messageLabel.anchor(top: bubbleView.topAnchor, paddingTop: 16,  left: bubbleView.leftAnchor, paddingLeft: 16, right: bubbleView.rightAnchor, paddingRight: 16, bottom: bubbleView.bottomAnchor, paddingBottom: 16)
        
        bubbleView.addSubview(messageImageView)
        //messageImageView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, right: bubbleView.rightAnchor, bottom: bubbleView.bottomAnchor)
        messageImageTopConstraint = messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor)
        messageImageTopConstraint.isActive = false
        messageImageBottomConstraint = messageImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor)
        messageImageBottomConstraint.isActive = false
        messageImageLeftConstraint = messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor)
        messageImageLeftConstraint.isActive = false
        messageImageRightConstraint = messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor)
        messageImageRightConstraint.isActive = false
        
    }
    
    func setupMessageCell(cell: ChatMessageCell, message: Message) {
        messageLabel.text = message.text
        
        if let imageURL = message.imageURL {
            messageImageView.loadImageUsingCache(from: imageURL)
            messageImageView.isHidden = false
            messageImageTopConstraint.isActive = true
            messageImageBottomConstraint.isActive = true
            messageImageLeftConstraint.isActive = true
            messageImageRightConstraint.isActive = true
            bubbleViewHeightConstraint.isActive = true
//            guard let imageHeight = message.imageHeight?.floatValue, let imageWidth = message.imageWidth?.floatValue else { return }
//            height = CGFloat(imageHeight / (imageWidth * 250))
//            messageImageHeightConstraint = messageImageView.heightAnchor.constraint(equalToConstant: height )
//            messageImageHeightConstraint.isActive = true
        } else {
            messageImageView.isHidden = true
            messageImageTopConstraint.isActive = false
            messageImageBottomConstraint.isActive = false
            messageImageLeftConstraint.isActive = false
            messageImageRightConstraint.isActive = false
            bubbleViewHeightConstraint.isActive = false
            //messageImageHeightConstraint.isActive = false
        }
        if message.senderId == FirebaseAuth.Auth.auth().currentUser?.uid {
            bubbleView.backgroundColor = .systemGreen
            messageLeftConstraint.isActive = false
            messageRightConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = .link
            messageRightConstraint.isActive = false
            messageLeftConstraint.isActive = true
        }
    }
}
