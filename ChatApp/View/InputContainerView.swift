//
//  InputContainerView.swift
//  ChatApp
//
//  Created by Gadgetzone on 03/08/21.
//

import UIKit

class InputContainerView: UIView {
    
    //MARK: - Properties
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1).withAlphaComponent(1)
        button.layer.cornerRadius = 25
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
    
    let sendMediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    lazy var textFieldContainerView: UIView = {
        let tv = UIView()
        tv.addSubview(inputTextField)
        tv.addSubview(sendMediaButton)
        tv.layer.cornerRadius = 20
        tv.backgroundColor = .darkGray
        sendMediaButton.anchor(top: tv.topAnchor, paddingTop: 10, right: tv.rightAnchor, paddingRight: 5, width: 30, height: 30)
        inputTextField.anchor(top: tv.topAnchor, left: tv.leftAnchor, right: sendMediaButton.leftAnchor, bottom: tv.bottomAnchor)
        return tv
    }()
    
    var messageLogController: MessageLogController? {
        didSet {
            sendButton.addTarget(messageLogController, action: #selector(MessageLogController.handleSendingOfMessage), for: .touchUpInside)
            sendMediaButton.addTarget(messageLogController, action: #selector(MessageLogController.sendImageButtonTpped), for: .touchUpInside)
        }
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInputContainerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    
    func setupInputContainerView() {
        backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        addSubview(sendButton)
        addSubview(textFieldContainerView)
        sendButton.anchor(top: topAnchor, right: rightAnchor, width: 50, height: 50)
        textFieldContainerView.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 10, right: sendButton.leftAnchor, paddingRight: 8, height: 50)
    }
}
