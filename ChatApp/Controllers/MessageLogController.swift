//
//  MessageLogController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import FirebaseAuth

class MessageLogController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1).withAlphaComponent(1)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleSendingOfMessage), for: .touchUpInside)
        return button
    }()
    
    let inputTextField: UITextField = {
        let inputField = UITextField()
        inputField.backgroundColor = .clear
        inputField.font = UIFont.systemFont(ofSize: 19)
        inputField.attributedPlaceholder = NSAttributedString(string: "Enter Message", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        inputField.textColor = .white
        inputField.layer.masksToBounds = true
        inputField.layer.cornerRadius = 20
        inputField.addPadding(.left(8))
        return inputField
    }()
    
    let sendImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(sendImageButtonTpped), for: .touchUpInside)
        return button
    }()
    
    lazy var textFieldContainerView: UIView = {
        let tv = UIView()
        tv.addSubview(inputTextField)
        tv.addSubview(sendImageButton)
        tv.layer.cornerRadius = 20
        tv.backgroundColor = .darkGray
        sendImageButton.anchor(top: tv.topAnchor, paddingTop: 10, right: tv.rightAnchor, paddingRight: 5, width: 30, height: 30)
        inputTextField.anchor(top: tv.topAnchor, left: tv.leftAnchor, right: sendImageButton.leftAnchor, bottom: tv.bottomAnchor)
        return tv
    }()
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        containerView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        containerView.addSubview(sendButton)
        containerView.addSubview(textFieldContainerView)
        sendButton.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, width: 50, height: 50)
        textFieldContainerView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, paddingLeft: 10, right: sendButton.leftAnchor, paddingRight: 8, height: 50)
        return containerView
    }()
    
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var inputContainerBottomAnchor: NSLayoutConstraint?
    let cellID = "cell"
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
        inputTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print("*****************deinit called******************")
    }
    
    // MARK: - Table view functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.setupMessageCell(cell: cell, message: message)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Configure Functions
    
    private func configureViewComponents() {
        tableView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellID)
        
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
    
    @objc func observeKeyboard() {
        let count = messages.count
        if count > 0 {
            let indexPath = IndexPath(row: count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    //MARK: - Handler Functions
    
    @objc func handleSendingOfMessage() {
        guard let message = inputTextField.text else { return }
        guard let uid = user!.id else { return }
        guard let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        guard let timestamp = NSDate().timeIntervalSince1970 as? Double else { return }
        FirebaseManager.shared.sendMessages(message: message, recieverId: uid, senderId: currentUserUid, timestamp: timestamp) { [weak self] success in
            if success {
                print("Sent SuccessFully!!")
                self?.inputTextField.text = nil
            }
        }
    }
    
    @objc func sendImageButtonTpped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
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
}

extension MessageLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage else { return }
        guard let uid = user!.id else { return }
        guard let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        guard let timestamp = NSDate().timeIntervalSince1970 as? Double else { return }
        FirebaseManager.shared.sendImagesInChat(image: image, recieverId: uid, senderId: currentUserUid, timestamp: timestamp) { success in
            if success {
                print("Image message sent!!")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
