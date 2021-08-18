//
//  TabBarController.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        tabBar.barTintColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        configureTabBar()
    }
    
    func configureTabBar() {
        let layout = UICollectionViewFlowLayout()
        
        let chatController = getNavigationController(vc: ChatController(collectionViewLayout: layout), selectedImage: (UIImage(systemName: "bubble.left.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal))!, unSelectedImage: (UIImage(systemName: "bubble.left.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal))!)
        
        let statusController = getNavigationController(vc: StatusController(), selectedImage: (UIImage(systemName: "circle.dashed", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal))!, unSelectedImage: (UIImage(systemName: "circle.dashed", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal))!)
        
        let profileController = getNavigationController(vc: ProfileController(), selectedImage: (UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal))!, unSelectedImage: (UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal))!)
        
        viewControllers = [chatController, statusController, profileController]
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    func getNavigationController(vc: UIViewController, selectedImage: UIImage, unSelectedImage: UIImage) -> UINavigationController{
        let controller = vc
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem.image = unSelectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}

