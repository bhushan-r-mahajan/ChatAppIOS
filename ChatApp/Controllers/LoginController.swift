//
//  LoginController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    //MARK: - Variables
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let emailContainer = UIView()
    let passwordContainer = UIView()
    
    let emailFieldLogo: UIImage! = {
        let button = UIImage(systemName: "envelope.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return button
    }()
    
    let passwordFieldLogo: UIImage! = {
        let button = UIImage(systemName: "lock.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return button
    }()
    
    let logoImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.image = #imageLiteral(resourceName: "LetsChatLogo")
        return imgView
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1).withAlphaComponent(1)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password ?", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have account ?", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string:"  Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginController()
    }
    
    //MARK: - Handlers
    
    private func configureLoginController() {
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, paddingTop: 60, left: view.leftAnchor, paddingLeft: 50, right: view.rightAnchor, paddingRight: 50, height: 200)
        
        emailTextField.StyleTextField(placeholder: "Email", isSecureText: false)
        view.addSubview(emailContainer)
        emailContainer.anchor(top: logoImageView.bottomAnchor, paddingTop: 24, left: view.leftAnchor, paddingLeft: 32, right: view.rightAnchor, paddingRight: 32, height: 50)
        emailContainer.textContainerView(view: emailContainer, image: emailFieldLogo, textField: emailTextField)
        
        passwordTextField.StyleTextField(placeholder: "Password", isSecureText: true)
        view.addSubview(passwordContainer)
        passwordContainer.anchor(top: emailContainer.bottomAnchor, paddingTop: 30, left: view.leftAnchor, paddingLeft: 32, right: view.rightAnchor, paddingRight: 32, height: 50)
        passwordContainer.textContainerView(view: passwordContainer, image: passwordFieldLogo, textField: passwordTextField)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: passwordContainer.bottomAnchor, paddingTop: 30, left: view.leftAnchor, paddingLeft: 60, right: view.rightAnchor, paddingRight: 60, height: 50)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchor(top: loginButton.bottomAnchor, paddingTop: 40, left: view.leftAnchor, paddingLeft: 60, right: view.rightAnchor, paddingRight: 60, height: 50)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(left: view.leftAnchor, paddingLeft: 70, right: view.rightAnchor, paddingRight: 70, bottom: view.bottomAnchor, paddingBottom: 40, height: 50)
    }
    
    private func showAlertForError(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Selector Functions
    
    @objc private func loginButtonTapped(sender: UIButton) {
        loginButton.animateButton(sender)
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            showAlertForError(title: "Failed to Login", message: "Email and Password cannot be empty. Try again !")
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                print("Error logging in !!!")
                return
            }
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc private func signUpButtonTapped() {
        let signUp = SignUpController()
        navigationController?.pushViewController(signUp, animated: true)
    }
    
    @objc private func forgotPasswordButtonTapped() {
        
    }
}
