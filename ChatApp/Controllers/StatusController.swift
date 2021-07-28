//
//  StatusController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit

class StatusController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradient(colorOne: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), colorTwo: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Status"
    }
}
