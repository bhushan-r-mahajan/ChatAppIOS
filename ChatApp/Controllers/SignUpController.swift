//
//  SignUpController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let nameContainer = UIView()
    let emailContainer = UIView()
    let passwordContainer = UIView()
    var selectedImage: UIImage?
    
    let nameFieldLogo: UIImage! = {
        let button = UIImage(systemName: "person.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return button
    }()
    
    
    let emailFieldLogo: UIImage! = {
        let button = UIImage(systemName: "envelope.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return button
    }()
    
    let passwordFieldLogo: UIImage! = {
        let button = UIImage(systemName: "lock.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return button
    }()
    
    let profileImage: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setBackgroundImage(UIImage(systemName: "person.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.layer.cornerRadius = 100
        button.addTarget(self, action: #selector(profileImageSelectorTapped), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1).withAlphaComponent(1)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have account ?", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string:"  Login", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(alreadyHaveAccountButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignUpController()
    }
    
    // MARK: - Configure Funtion
    
    private func configureSignUpController() {
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(profileImage)
        profileImage.anchor(top: view.topAnchor, paddingTop: 70, width: 200, height: 200)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        nameTextField.StyleTextField(placeholder: "Fullname..", isSecureText: false)
        view.addSubview(nameContainer)
        nameContainer.anchor(top: profileImage.bottomAnchor, paddingTop: 40, left: view.leftAnchor, paddingLeft: 32, right: view.rightAnchor, paddingRight: 32, height: 50)
        nameContainer.textContainerView(view: nameContainer, image: nameFieldLogo, textField: nameTextField)
        
        emailTextField.StyleTextField(placeholder: "Email..", isSecureText: false)
        view.addSubview(emailContainer)
        emailContainer.anchor(top: nameContainer.bottomAnchor, paddingTop: 24, left: view.leftAnchor, paddingLeft: 32, right: view.rightAnchor, paddingRight: 32, height: 50)
        emailContainer.textContainerView(view: emailContainer, image: emailFieldLogo, textField: emailTextField)
        
        passwordTextField.StyleTextField(placeholder: "Password..", isSecureText: true)
        view.addSubview(passwordContainer)
        passwordContainer.anchor(top: emailContainer.bottomAnchor, paddingTop: 30, left: view.leftAnchor, paddingLeft: 32, right: view.rightAnchor, paddingRight: 32, height: 50)
        passwordContainer.textContainerView(view: passwordContainer, image: passwordFieldLogo, textField: passwordTextField)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: passwordContainer.bottomAnchor, paddingTop: 30 ,left: view.leftAnchor, paddingLeft: 70, right: view.rightAnchor, paddingRight: 70, height: 50)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, paddingLeft: 70, right: view.rightAnchor, paddingRight: 70, bottom: view.bottomAnchor, paddingBottom: 40, height: 50)
    }
    
    private func showAlertForError(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Selector Functions
    
    @objc private func profileImageSelectorTapped() {
        presentPhotoSelectionActionSheet()
    }
    
    @objc private func alreadyHaveAccountButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func signUpButtonTapped(sender: UIButton) {
        signUpButton.animateButton(sender)
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, !name.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            showAlertForError(title: "Failed to Login", message: "Fields cannot be empty. Try again !")
            return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil, let uid = result?.user.uid else {
                return
            }
            
            guard let imageData = self?.selectedImage?.jpegData(compressionQuality: 0.1) else { return }
            let imageName = NSUUID().uuidString
            FirebaseManager.shared.uploadProfilePicture(with: imageData, fileName: imageName) { result in
                switch result {
                case .success(let profileImageURL):
                    print(profileImageURL)
                    let referance = Database.database().reference()
                    let user = ["name": name, "email": email, "profilePhotoURL": profileImageURL, "id": uid]
                    referance.child("users").child(uid).updateChildValues(user) { error, _ in
                        guard error == nil else {
                            print("Error storing data: \(String(describing: error))")
                            return
                        }
                    }
                    
                case .failure(let error): print("Error uploading Photo after user created!!\(error.localizedDescription)")
                }
            }
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - Image Selector Delegate

extension SignUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoSelectionActionSheet() {
        let sheet = UIAlertController(title: "Select Profile Picture", message: "Choose a photo from gallery or click a photo.", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] (_) in
            self?.presentPhotoPicker()
        }))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] (_) in
            self?.presentCamera()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileImage.setImage(image, for: .normal)
            selectedImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
