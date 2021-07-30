//
//  ChatCell.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class ChatCell: UICollectionViewCell {
    
    //MARK: - Variables
    
    static let reuseIdentifier = "ChatCell"
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    let nameLabelField: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    let messageLabelField: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    
    // MARK: - Init
    
    weak var message: Message? {
        didSet {
            if let id = message?.checkId() {
                FirebaseManager.shared.fetchPerticularUser(id: id) { dictionary in
                    self.nameLabelField.text = dictionary["name"] as? String
                    guard let profileImageUrl = dictionary["profilePhotoURL"] as? String else { return }
                    let URL = NSURL(string: profileImageUrl)
                    self.profileImageView.sd_setImage(with: URL as URL?, completed: nil)
                }
                messageLabelField.text = message?.text
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure Functions
    
    func configureCell() {
        addSubview(profileImageView)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.anchor(left: leftAnchor, paddingLeft: 10, width: 70, height: 70)
        
        addSubview(nameLabelField)
        nameLabelField.anchor(top: topAnchor, paddingTop: 10, left: profileImageView.rightAnchor, paddingLeft: 20, height: 24)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: topAnchor, paddingTop: 10, right: rightAnchor, width: 100, height: 24)
        
        addSubview(messageLabelField)
        messageLabelField.anchor(top: nameLabelField.bottomAnchor, paddingTop: 10 , left: profileImageView.rightAnchor, paddingLeft: 20, right: rightAnchor, height: 24)
    }
}

