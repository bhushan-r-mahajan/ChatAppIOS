//
//  Extensions.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit


extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0, left: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = 0, right: NSLayoutXAxisAnchor? = nil, paddingRight: CGFloat? = 0, bottom: NSLayoutYAxisAnchor? = nil, paddingBottom: CGFloat? = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft!).isActive = true
        }
        
        if let right = right {
            if let paddingRight = paddingRight{
                rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            }
        }
        
        if let bottom = bottom {
            if let paddingBottom = paddingBottom {
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            }
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func textContainerView(view: UIView, image: UIImage, textField: UITextField) {
        
        view.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 1
        view.addSubview(imageView)
        imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(textField)
        textField.anchor(left: imageView.leftAnchor, paddingLeft: 30, right: view.rightAnchor, paddingRight: 8)
        textField.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 1, alpha: 1)
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, paddingLeft: 8, right: view.rightAnchor, paddingRight: 0, bottom: view.bottomAnchor, paddingBottom: 0, height: 1)
    }
    
    func labelContainerView(view: UIView, image: UIImage, labelField: UILabel) {
        
        view.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 1
        view.addSubview(imageView)
        imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(labelField)
        labelField.anchor(left: imageView.leftAnchor, paddingLeft: 30, right: view.rightAnchor, paddingRight: 8)
        labelField.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.black.withAlphaComponent(1)
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, paddingLeft: 8, right: view.rightAnchor, paddingRight: 0, bottom: view.bottomAnchor, paddingBottom: 0, height: 1)
    }
}

extension UITextField {
    
    func StyleTextField(placeholder: String, isSecureText: Bool) {
        self.borderStyle = .none
        self.font = UIFont.systemFont(ofSize: 19)
        self.textColor = .white
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.isSecureTextEntry = isSecureText
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

extension UILabel {
    
    func StyleLabelField() {
        self.font = UIFont.systemFont(ofSize: 19)
        self.textColor = .white
    }
}

extension UIView {
    
    func setGradient(colorOne: UIColor, colorTwo: UIColor) {
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = bounds
        backgroundLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        backgroundLayer.locations = [0.0, 1.0]
        backgroundLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    func animateButton(_ viewToAnimate: UIView) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: .curveEaseInOut) {
            
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            
        } completion: { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}



//extension UIImageView {
//
//    func loadImageUsingCache(from imgURL: String) -> URLSessionDataTask? {
//        guard let url = URL(string: imgURL) else { return nil }
//
//        // set initial image to nil so it doesn't use the image from a reused cell
//        image = nil
//
//        // check if the image is already in the cache
//        if let imageToCache = imageCache.object(forKey: imgURL as NSString) {
//            self.image = imageToCache
//            return nil
//        }
//
//        // download the image asynchronously
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let err = error {
//                print(err)
//                return
//            }
//
//            DispatchQueue.main.async {
//                // create UIImage
//                let imageToCache = UIImage(data: data!)
//                // add image to cache
//                imageCache.setObject(imageToCache!, forKey: imgURL as NSString)
//                self.image = imageToCache
//            }
//        }
//        task.resume()
//        return task
//    }
//}

let imageCache = NSCache<NSString, UIImage>()
//let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCache(from urlString: String) {
        
        image = nil
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            image = cachedImage
            return
        }
        let profilePhotoURL = NSURL(string: urlString)
        URLSession.shared.dataTask(with: profilePhotoURL! as URL) { data, response, error in
            guard error == nil else {
                print("Error while downloading Image!!!")
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

extension UITextField {
    
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }
    
    func addPadding(_ padding: PaddingSide) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        
        switch padding {
        
        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always
            
        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always
            
        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
}
