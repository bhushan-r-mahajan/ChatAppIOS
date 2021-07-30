//
//  ViewController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Variables
    
    let noChatsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Chats"
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    var messages = [Message]()
    var user: Users?
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        observeUserMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    //MARK: - Configure Funtions
    
    private func configureHomeController() {
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.reuseIdentifier)
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        collectionView.backgroundColor = .clear
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Chats"
        navigationController?.navigationBar.barStyle = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.bubble", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(newConversationButtonTapped))
        
        view.addSubview(noChatsLabel)
    }
    
    
    //MARK: - Handler Functions
    
    private func isUserLoggedIn() {
        if Auth.auth().currentUser == nil {
            let login = LoginController()
            let nav = UINavigationController(rootViewController: login)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        configureHomeController()
    }
    
    private func observeUserMessages() {
        FirebaseManager.shared.observeUserMessages() { [weak self] userMessages in
            self?.messages = userMessages
            print(userMessages.count)
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    func showMessageControllerForUser(user: Users) {
        let messageController = MessageLogController()
        messageController.user = user
        let nav = UINavigationController(rootViewController: messageController)
        nav.modalPresentationStyle = .fullScreen
        navigationController?.present(nav, animated: true, completion: nil)
    }
    
    func fetchuser(chatpartnerID: String) {
        FirebaseManager.shared.fetchCurrentUser(with: chatpartnerID) { [weak self] result in
            switch result {
            case .success(let dictionary):
                let user = Users()
                user.id = chatpartnerID
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.id = dictionary["id"] as? String
                user.profileImageURL = dictionary["profilePhotoURL"] as? String
                self?.showMessageControllerForUser(user: user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: - Objc Functions
    
    @objc func newConversationButtonTapped() {
        let newChatController = NewConversationController()
        newChatController.chatController = self
        let nav = UINavigationController(rootViewController: newChatController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - CollectionViewController Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.reuseIdentifier, for: indexPath) as! ChatCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        guard let chatpartnerID = message.checkId() else { return }
        fetchuser(chatpartnerID: chatpartnerID)
    }
    
    //MARK: - CollectionViewFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
}

