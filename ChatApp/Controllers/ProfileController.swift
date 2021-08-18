//
//  ProfileController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class ProfileController: UIViewController {
    
    // MARK: - Properties
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 75
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let nameField: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let emailField: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1).withAlphaComponent(1)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        configureNavigationBar()
        configureViewComponents()
        fetchUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
    }
    
    
    // MARK: - Configure Functions
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Profile"
    }
    
    private func configureViewComponents() {
        view.addSubview(profileImage)
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.anchor(top: view.topAnchor, paddingTop: 170, width: 150, height: 150)
        
        view.addSubview(nameField)
        nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameField.anchor(top: profileImage.bottomAnchor, paddingTop: 40)
        
        view.addSubview(emailField)
        emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailField.anchor(top: nameField.bottomAnchor, paddingTop: 30, left: view.leftAnchor, paddingLeft: 30, height: 50)
        
        view.addSubview(logoutButton)
        logoutButton.anchor(top: emailField.bottomAnchor, paddingTop: 30, left: view.leftAnchor, paddingLeft: 60, right: view.rightAnchor, paddingRight: 60, height: 50)
    }
    
    private func showAlertForError(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchUserProfile() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            return
        }
        FirebaseManager.shared.fetchPerticularUser(id: uid) { dictionary in
            self.nameField.text = dictionary["name"] as? String
            self.emailField.text = dictionary["email"] as? String
            guard let urlString = dictionary["profilePhotoURL"] as? String else { return }
            let URL = NSURL(string: urlString)
            self.profileImage.sd_setImage(with: URL as URL?, completed: nil)
        }
    }
    
    // MARK: - Navigation
    
    @objc private func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            let login = LoginController()
            let nav = UINavigationController(rootViewController: login)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("Error loggin out !!")
            showAlertForError(title: "Log Out Failed", message: "Something went wrong at Loggin out !")
        }
    }
}

