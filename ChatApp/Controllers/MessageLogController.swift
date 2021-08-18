//
//  MessageLogController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import FirebaseAuth
import MobileCoreServices
import AVFoundation

class MessageLogController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    lazy var inputContainerView: InputContainerView = {
        let containerView = InputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80))
        containerView.messageLogController = self
        return containerView
    }()
    
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var inputContainerBottomAnchor: NSLayoutConstraint?
    var messages = [Message]()
    
    // MARK: - Init
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        setupKeyboardObserver()
        inputContainerView.inputTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table view functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.text != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseIdentifier, for: indexPath) as! ChatMessageCell
            cell.message = message
            return cell
        } else if message.imageURL != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatImageCell.reuseIdentifier, for: indexPath) as! ChatImageCell
            cell.message = message
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Configure Functions
    
    private func configureViewComponents() {
        tableView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseIdentifier)
        tableView.register(ChatImageCell.self, forCellReuseIdentifier: ChatImageCell.reuseIdentifier)
        
        navigationController?.navigationBar.barStyle = .black
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    private func observeMessages() {
        guard let userID = self.user?.id else { return }
        FirebaseManager.shared.observePerticularMessage(for: userID) { [weak self] userMessages in
            self?.messages = userMessages
            guard let count = self?.messages.count else { return }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                let indexPath = IndexPath(row: count - 1, section: 0)
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(observeKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func timestamp() -> String? {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a dd/MM"
        return formatter.string(from: now)
    }
    
    //MARK: - Handler Functions
    
    @objc func observeKeyboard() {
        let count = messages.count
        if count > 2 {
            let indexPath = IndexPath(row: count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleSendingOfMessage() {
        guard let message = inputContainerView.inputTextField.text, let recieverID = user!.id, let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid, let timestamp =  timestamp(), let recieverName = user?.name, let profileURL = user?.profilePhotoURL else { return }
        
        FirebaseManager.shared.sendMessages(recieverName: recieverName, recieverProfilePhoto: profileURL, message: message, recieverId: recieverID, senderId: currentUserUid, timestamp: timestamp) { [weak self] success in
            if success {
                self?.inputContainerView.inputTextField.text = nil
            }
        }
    }
    
    @objc func sendImageButtonTpped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        vc.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(vc, animated: true)
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TextField Delegate Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendingOfMessage()
        return true
    }
    
    func thumbnailImageForFile(fileURL: NSURL) -> UIImage? {
        let assest = AVAsset(url: fileURL as URL)
        let imageGenerator = AVAssetImageGenerator(asset: assest)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch let error{
            print(error)
        }
        return nil
    }
}

extension MessageLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let recieverID = user!.id, let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid, let timestamp = timestamp(), let recieverName = user?.name, let profileURL = user?.profilePhotoURL else { return }
        
        if let video = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerMediaURL")] as? NSURL {
            let videoURL = video.filePathURL as NSURL?
            guard let thumbnailImage = self.thumbnailImageForFile(fileURL: videoURL!) else { return }
            FirebaseManager.shared.getThumbnailImageURl(image: thumbnailImage) { url in
                let imageURl = url
                FirebaseManager.shared.sendVideosInChat(videoURL: videoURL! as URL, imageURL: imageURl, recieverId: recieverID, senderId: currentUserUid, timestamp: timestamp) { success in
                    if success {
                        print("Video message sent!!")
                    }
                }
            }
        } else {
            if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
                FirebaseManager.shared.sendImagesInChat(recieverName: recieverName, recieverProfilePhoto: profileURL, image: image, recieverId: recieverID, senderId: currentUserUid, timestamp: timestamp) { success in
                    if success {}
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
