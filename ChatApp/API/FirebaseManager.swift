//
//  FirebaseManager.swift
//  ChatApp
//
//  Created by Gadgetzone on 25/07/21.
//

import UIKit
import Firebase

class FirebaseManager {
    
    //MARK: - Properties
    
    static let shared = FirebaseManager()
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    enum FirebaseError: Error {
        case FailedToFetchUser
        case FailedToDownloadUrl
        case FailedToUploadImage
    }
    
    //MARK: - Fetch Functions
    
    func fetchCurrentUser(with uid: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        database.child("users").child(uid).observeSingleEvent(of: .value) { snapShot in
            if let dictionary = snapShot.value as? [String: Any] {
                completion(.success(dictionary))
            }
        }
    }
    
    func fetchAllUsers(completed: @escaping ([Users]) -> ()) {
        var users = [Users]()
        database.child("users").observe(.childAdded) { snapShot in
            if let dict = snapShot.value as? [String: Any] {
                let user = Users()
                user.name = dict["name"] as? String
                user.email = dict["email"] as? String
                user.profileImageURL = dict["profilePhotoURL"] as? String
                user.id = dict["id"] as? String
                users.append(user)
            }
            completed(users)
        }
    }
    
    func fetchPerticularUser(id: String, completion: @escaping ([String: Any]) -> Void) {
        database.child("users").child(id).observeSingleEvent(of: .value) { snapShot in
            guard let dictionary = snapShot.value as? [String: Any] else {
                return
            }
            completion(dictionary)
        }
    }
    
    func fetchUsersFromLatestMessage(completed: @escaping ([String: Any]) -> ()) {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        database.child("userMessages").child(uid).observe(.childAdded) { snapShot in
            let id = snapShot.key
            self.database.child("users").child(id).observe(.value) { snapShot in
                if let dictionary = snapShot.value as? [String: Any] {
                    completed(dictionary)
                }
            }
        }
    }
    
    func fetchTimeStamp(recieverId: String, completion: @escaping (Double) -> Void) {
        database.child("messages").child(recieverId).observeSingleEvent(of: .value) { snapShot in
            if let dictionary = snapShot.value as? [String: Any] {
                guard let timestamp = dictionary["timestamp"] as? Double else {
                    print("Error fetching timestamp")
                    return
                }
                print(timestamp)
                completion(timestamp)
            }
        }
    }
    
    //MARK: - Upload Functions
    
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                completion(.failure(FirebaseError.FailedToUploadImage))
                return
            }
            self?.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(FirebaseError.FailedToDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    //MARK: - Send Messages Function
    
    func sendMessages(message: String, recieverId: String, senderId: String, timestamp: Double, completion: @escaping (Bool) -> Void) {
        let values = ["text": message, "recieverId": recieverId, "senderId": senderId, "timestamp": timestamp] as [String : Any]
        database.child("latestMessage").child(senderId).child(recieverId).setValue(values)
        let ref = database.child("messages")
        let childRef = ref.childByAutoId()
        childRef.updateChildValues(values) { [weak self] error, ref in
            guard error == nil else {
                print("Failed to send Mesaage!!")
                completion(false)
                return
            }
            guard let messageId = childRef.key else { return }
            self?.database.child("userMessages").child(senderId).child(recieverId).updateChildValues([messageId: "1"])
            self?.database.child("userMessages").child(recieverId).child(senderId).updateChildValues([messageId: "1"])
            completion(true)
        }
    }
    
    //MARK: - Send Images Function
    
    func sendImagesInChat(image: UIImage, recieverId: String, senderId: String, timestamp: Double, completion: @escaping (Bool) -> Void) {
        let imageName = NSUUID().uuidString
        guard let imagedata = image.jpegData(compressionQuality: 0.2) else {
            print("Error getting imageData!!")
            return
        }
        storage.child("messageImages").child(imageName).putData(imagedata, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print("Error uploading image !!!")
                return
            }
            self.storage.child("messageImages").child(imageName).downloadURL { url, error in
                guard let imageURL = url, error == nil else {
                    print("Error downloading image url!!")
                    return
                }
                print(imageURL)
                let values = ["imageURL": imageURL.absoluteString, "recieverId": recieverId, "senderId": senderId, "timestamp": timestamp, "imageHeight": image.size.height, "imageWidth": image.size.width] as [String : Any]
                self.database.child("latestMessage").child(senderId).child(recieverId).setValue(values)
                let ref = self.database.child("messages")
                let childRef = ref.childByAutoId()
                childRef.updateChildValues(values) { [weak self] error, ref in
                    guard error == nil else {
                        print("Failed to send Mesaage!!")
                        completion(false)
                        return
                    }
                    guard let messageId = childRef.key else { return }
                    self?.database.child("userMessages").child(senderId).child(recieverId).updateChildValues([messageId: "1"])
                    self?.database.child("userMessages").child(recieverId).child(senderId).updateChildValues([messageId: "1"])
                    completion(true)
                }
            }
        }
    }
    
    //MARK: - Send Videos Function
    
    func getThumbnailImageURl(image: UIImage, completion: @escaping (_ imageURL: String) -> Void) {
        let imageName = NSUUID().uuidString
        guard let imagedata = image.jpegData(compressionQuality: 0.2) else {
            print("Error getting imageData!!")
            return
        }
        storage.child("thumbnailImages").child(imageName).putData(imagedata, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print("Error uploading image !!!")
                return
            }
            self.storage.child("thumbnailImages").child(imageName).downloadURL { url, error in
                guard let imageURL = url, error == nil else {
                    print("Error downloading image url!!")
                    return
                }
                print(imageURL.absoluteString)
                completion(imageURL.absoluteString)
            }
        }
    }
    
    func sendVideosInChat(videoURL: URL, imageURL: String, recieverId: String, senderId: String, timestamp: Double, completion: @escaping (Bool) -> Void) {
        let videoName = NSUUID().uuidString
        storage.child("messageVideos").child(videoName).putFile(from: videoURL, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print("Error uploading Video !!!")
                return
            }
            print("Video saved to db successfully")
            self.storage.child("messageVideos").child(videoName).downloadURL { url, error in
                guard let videoDownloadURL = url, error == nil else {
                    print("Error downloading Video url!!")
                    return
                }
                print(videoDownloadURL)
                let values = ["videoURL": videoDownloadURL.absoluteString, "imageURL": imageURL, "recieverId": recieverId, "senderId": senderId, "timestamp": timestamp] as [String : Any]
                self.database.child("latestMessage").child(senderId).child(recieverId).setValue(values)
                let ref = self.database.child("messages")
                let childRef = ref.childByAutoId()
                childRef.updateChildValues(values) { [weak self] error, ref in
                    guard error == nil else {
                        print("Failed to send Mesaage!!")
                        completion(false)
                        return
                    }
                    guard let messageId = childRef.key else { return }
                    self?.database.child("userMessages").child(senderId).child(recieverId).updateChildValues([messageId: "1"])
                    self?.database.child("userMessages").child(recieverId).child(senderId).updateChildValues([messageId: "1"])
                    completion(true)
                }
                
            }
        }
    }
    
    //MARK: - Fetch messages For ChatController
    
    //    func observeUserMessages(completed: @escaping ([Message]) -> ()) {
    //        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
    //        var messages = [Message]()
    //        var messagesDictionary = [String: Message]()
    //        database.child("latestMessage").child(uid).observe(.childAdded) { snapshot in
    //            let recieverID = snapshot.key
    //            print(recieverID)
    //            self.database.child("latestMessage").child(uid).child(recieverID).observeSingleEvent(of: .value) { snapShot in
    //                if let dictionary = snapShot.value as? [String: Any] {
    //                    print(dictionary)
    //                    let message = Message()
    //                    message.recieverId = dictionary["recieverId"] as? String
    //                    message.senderId = dictionary["senderId"] as? String
    //                    message.text = dictionary["text"] as? String
    //                    message.timestamp = dictionary["timestamp"] as? Double
    //                    if let chatPartnerID = message.checkId() {
    //                        messagesDictionary[chatPartnerID] = message
    //                        messages = Array(messagesDictionary.values)
    //                        messages.sort { message1, message2 in
    //                            return Double(message1.timestamp!) > Double(message2.timestamp!)
    //                        }
    //                    }
    //                    completed(messages)
    //                }
    //            }
    //        }
    //    }
    
    func observeUserMessages(completed: @escaping ([Message]) -> ()) {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        var messages = [Message]()
        var messagesDictionary = [String: Message]()
        database.child("userMessages").child(uid).observe(.childAdded) { snapShot in
            let userID = snapShot.key
            self.database.child("userMessages").child(uid).child(userID).observe(.childAdded) { datasnapShot in
                let messageId = datasnapShot.key
                self.database.child("messages").child(messageId).observeSingleEvent(of: .value) { snapShottt in
                    
                    if let dictionary = snapShottt.value as? [String: Any] {
                        let message = Message()
                        message.recieverId = dictionary["recieverId"] as? String
                        message.senderId = dictionary["senderId"] as? String
                        message.text = dictionary["text"] as? String
                        message.timestamp = dictionary["timestamp"] as? Double
                        
                        if let chatPartnerID = message.checkId() {
                            messagesDictionary[chatPartnerID] = message
                            messages = Array(messagesDictionary.values)
                        }
                        completed(messages)
                    }
                }
            }
        }
    }
    
    //MARK: - Fetch All Messages In MessageLogController
    
    func observePerticularMessage(for userWithID: String, completion: @escaping ([Message]) -> Void) {
        var messages = [Message]()
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        database.child("userMessages").child(uid).child(userWithID).observe(.childAdded) { [weak self] snapShot in
            let messageID = snapShot.key
            self?.database.child("messages").child(messageID).observeSingleEvent(of: .value) { dataSnapshot in
                guard let dictionary = dataSnapshot.value as? [String: Any] else { return }
                let message = Message()
                message.recieverId = dictionary["recieverId"] as? String
                message.senderId = dictionary["senderId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? Double
                message.imageURL = dictionary["imageURL"] as? String
                messages.append(message)
                
                completion(messages)
            }
        }
    }
}

