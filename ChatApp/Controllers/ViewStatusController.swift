//
//  ViewStatusController.swift
//  ChatApp
//
//  Created by Gadgetzone on 10/08/21.
//

import UIKit
import SDWebImage

class ViewStatusController: UIViewController {
    
    //MARK:- Properties
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let leftTapGestureView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let rightTapGestureView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var user: Users? {
        didSet {
            fetchStatus()
        }
    }
    
    var imageURL: String? {
        didSet {
                guard let URL = URL(string: self.imageURL!) else { return }
                self.imageView.sd_setImage(with: URL, completed: nil)
        }
    }
    
    var imagesArray = [String]()
    var index: Int = -1
    var timer: Timer!
    
    //MARK:- Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        setTimer()
    }
    
    //MARK:- Configure Functions
    
    func configureViewComponents() {
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, paddingTop: 100, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        imageView.addSubview(leftTapGestureView)
        view.addSubview(leftTapGestureView)
        leftTapGestureView.anchor(top: view.topAnchor, paddingTop: 100, left: view.leftAnchor, bottom: view.bottomAnchor, width: 150)
        view.addSubview(rightTapGestureView)
        rightTapGestureView.anchor(top: view.topAnchor, paddingTop: 100, right: view.rightAnchor, bottom: view.bottomAnchor, width: 150)
        configureTapGestures()
    }
    
    func configureTapGestures() {
        let leftGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(leftTapGestureTapped))
        leftGestureRecogniser.numberOfTapsRequired = 1
        leftGestureRecogniser.numberOfTouchesRequired = 1
        leftTapGestureView.addGestureRecognizer(leftGestureRecogniser)
        
        let rightGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(rightTapGestureTapped))
        rightGestureRecogniser.numberOfTapsRequired = 1
        rightGestureRecogniser.numberOfTouchesRequired = 1
        rightTapGestureView.addGestureRecognizer(rightGestureRecogniser)
    }
    
    @objc func leftTapGestureTapped() {
        previousImage()
    }
    
    @objc func rightTapGestureTapped() {
        nextImage()
    }
    
    //MARK:- API Call
    
    func fetchStatus() {
        guard let userID = user?.id else { return }
        FirebaseManager.shared.fetchUserStatus(user: userID) { status in
            self.imagesArray = status
            self.imageURL = self.imagesArray.first
        }
        updateIndex(indexValue: 1)
    }
    
    //MARK:- Timer Configuration
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(dismissViewConroller), userInfo: nil, repeats: true)
    }
    
    func resetTimer() {
        stopTimer()
        setTimer()
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func updateIndex(indexValue: Int) {
        index += indexValue
    }
    
    @objc func dismissViewConroller() {
        updateIndex(indexValue: 1)
        if imagesArray.count > index && index > -1 {
            imageURL = imagesArray[index]
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Navigation Functions
    
    func nextImage() {
        updateIndex(indexValue: 1)
        if index < imagesArray.count {
            imageURL = imagesArray[index]
            resetTimer()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func previousImage() {
        updateIndex(indexValue: -1)
        if index < imagesArray.count && index > -1 {
            imageURL = imagesArray[index]
            resetTimer()
        }
        if index < 0 {
            index = 0
        }
    }
}
