//
//  StatusController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import MobileCoreServices
import AVFoundation

class StatusController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(StatusCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        return table
    }()
    
    var statusArray = [Status]()
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        configureTableView()
        fetchStatus()
    }
    
    //MARK: - Configuration Functions
    
    func configureViewComponents() {
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Status"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "memories.badge.plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(uploadStatusButtonTapped))
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    func fetchStatus() {
        FirebaseManager.shared.fetchLatestUserStatus { latestStatus in
            self.statusArray = latestStatus
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func showViewStatusControllerForUser(user: Users) {
        let viewStatusController = ViewStatusController()
        viewStatusController.user = user
        viewStatusController.modalPresentationStyle = .fullScreen
        navigationController?.present(viewStatusController, animated: true, completion: nil)
    }
    
    @objc func uploadStatusButtonTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        vc.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(vc, animated: true)
    }
    
    //MARK: - TableView Datasource & Delegate Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StatusCell
        let user = statusArray[indexPath.row].user
        cell.user = user
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showViewStatusControllerForUser(user: statusArray[indexPath.row].user)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension StatusController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            FirebaseManager.shared.uploadStatusImage(image: image) { success in
                if !success {
                    print("Error uploading status.")
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
