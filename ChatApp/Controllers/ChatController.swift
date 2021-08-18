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
    
    var chats = [Chats]()
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        fetchUsersAndMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Configure Funtions
    
    private func configureHomeController() {
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.reuseIdentifier)
        view.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        collectionView.backgroundColor = .clear
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Chats"
        navigationController?.navigationBar.barStyle = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.bubble", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(newConversationButtonTapped))
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
    
    func fetchUsersAndMessages() {
        FirebaseManager.shared.fetchUsersFromLatestMessage { conversations in
//            conversations.sort { message1, message2 in
//                message1.message.timestamp >= message2.message.timestamp
//            }
            self.chats = conversations
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
        return chats.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.reuseIdentifier, for: indexPath) as! ChatCell
        let chats = chats[indexPath.row]
        cell.chat = chats
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        showMessageControllerForUser(user: chats[indexPath.row].user)
    }
    
    //MARK: - CollectionViewFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}

