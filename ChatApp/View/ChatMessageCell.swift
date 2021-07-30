//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Gadgetzone on 26/07/21.
//

import UIKit
import FirebaseAuth

class ChatMessageCell: UITableViewCell {
    
    static let reuseIdentifier = "cell"
    
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
    
    var message: Message? {
        didSet {
            setupMessageCell()
        }
    }
    
    var bubbleViewLeftConstraint: NSLayoutConstraint!
    var bubbleViewRightConstraint: NSLayoutConstraint!
    
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
        bubbleView.anchor(top: topAnchor, paddingTop: 10, bottom: bottomAnchor, paddingBottom: 10)
        bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        bubbleViewLeftConstraint = bubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10)
        bubbleViewLeftConstraint.isActive = false
        bubbleViewRightConstraint = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        bubbleViewRightConstraint.isActive = false
        
        bubbleView.addSubview(messageLabel)
        messageLabel.anchor(top: bubbleView.topAnchor, paddingTop: 10,  left: bubbleView.leftAnchor, paddingLeft: 10, right: bubbleView.rightAnchor, paddingRight: 10, bottom: bubbleView.bottomAnchor, paddingBottom: 10)
    }
    
    func setupMessageCell() {
        guard let message = message else { return }
        messageLabel.text = message.text
        if message.senderId == FirebaseAuth.Auth.auth().currentUser?.uid {
            bubbleView.backgroundColor = .systemGreen
            bubbleViewLeftConstraint.isActive = false
            bubbleViewRightConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = .link
            bubbleViewRightConstraint.isActive = false
            bubbleViewLeftConstraint.isActive = true
        }
    }
}
