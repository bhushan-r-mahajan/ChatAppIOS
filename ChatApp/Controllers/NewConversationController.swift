//
//  NewConversationController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import FirebaseDatabase

class NewConversationController: UIViewController {
    
    // MARK: - Properties
    
    let cellID = "cell"
    weak var chatController: ChatController?
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UserCell.self, forCellReuseIdentifier: cellID)
        return table
    }()
    
    private let noFriends: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No Friends"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    private let searchController = UISearchController()
    private var users = [Users]()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNewConversationController()
        configureSearchController()
        fetchUsers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Configure Functions
    
    private func configureSearchController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Find Friend"
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        searchController.loadViewIfNeeded()
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search Notes"
    }
    
    private func configureNewConversationController() {
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(noFriends)
        noFriends.center = view.center
    }
    
    private func fetchUsers() {
        FirebaseManager.shared.fetchAllUsers { [weak self] allUsers in
            self?.users = allUsers
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableviewDelegate & Functions

extension NewConversationController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected")
        dismiss(animated: false) {
            let user = self.users[indexPath.row]
            self.chatController?.showMessageControllerForUser(user: user)
        }
    }
}

// MARK: - TableviewDatasource & Functions

extension NewConversationController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.user = user
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - SearchBarDelegate & Functions

extension NewConversationController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
    }
}
