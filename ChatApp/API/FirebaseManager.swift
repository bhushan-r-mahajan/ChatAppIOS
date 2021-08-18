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
        case FailedToSendMessage
        case ErrorGettingImageData
        case ErrorDownloadingImageURL
        case ErrorUploadingImageURL
        case ErrorUploadingVideo
        case ErrorDownloadingVideoURL
    }
    
    //MARK: - Fetch Functions
    
    func fetchAllUsers(completed: @escaping ([Users]) -> ()) {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        var users = [Users]()
        database.child(StringConstants.users).observe(.childAdded) { snapShot in
            if let dict = snapShot.value as? [String: Any] {
                let user = Users(dictionary: dict)
                if user.id != uid {
                    users.append(user)
                }
                completed(users)
            }
        }
    }
    
    func fetchPerticularUser(id: String, completion: @escaping ([String: Any]) -> Void) {
        database.child(StringConstants.users).child(id).observeSingleEvent(of: .value) { snapShot in
            guard let dictionary = snapShot.value as? [String: Any] else {
                return
            }
            completion(dictionary)
        }
    }
    
    func fetchUsersFromLatestMessage(completed: @escaping ([Chats]) -> ()) {
        var chats = [Chats]()
        var messagesDictionary = [String: Chats]()
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        database.child(StringConstants.userMessages).child(uid).observe(.childAdded) { snapShot in
            
            self.fetchPerticularUser(id: snapShot.key) { userDictionary in
                let user = Users(dictionary: userDictionary)
                
                self.database.child(StringConstants.userMessages).child(uid).child(snapShot.key).child(StringConstants.recent_Message).observe(.value) { snapshot in
                    guard let id = snapshot.value as? String else { return }
                    self.database.child(StringConstants.messages).child(id).observe(.value) { dataSnapShot in
                        if let dict =  dataSnapShot.value as? [String: Any] {
                            let message = Message(dictionary: dict)
                            let chat = Chats(user: user, message: message)
                            if let chatPartnerID = message.checkId() {
                                messagesDictionary[chatPartnerID] = chat
                                chats = Array(messagesDictionary.values)
                            }
                            completed(chats)
                        }
                    }
                }
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
    
    func sendMessages(recieverName: String, recieverProfilePhoto: String, message: String, recieverId: String, senderId: String, timestamp: String, completion: @escaping (Bool) -> Void) {
        
        let values = [StringConstants.text: message, StringConstants.recieverId: recieverId, StringConstants.senderId: senderId, StringConstants.timestamp: timestamp] as [String : Any]
        let ref = database.child(StringConstants.messages)
        let childRef = ref.childByAutoId()
        childRef.updateChildValues(values) { [weak self] error, ref in
            guard error == nil else {
                print(FirebaseError.FailedToSendMessage)
                completion(false)
                return
            }
            guard let messageId = childRef.key else { return }
            self?.database.child(StringConstants.userMessages).child(senderId).child(recieverId).updateChildValues([messageId: "1"])
            self?.database.child(StringConstants.userMessages).child(recieverId).child(senderId).updateChildValues([messageId: "1"])
            
            self?.database.child(StringConstants.userMessages).child(senderId).child(recieverId).child(StringConstants.recent_Message).setValue(messageId)
            self?.database.child(StringConstants.userMessages).child(recieverId).child(senderId).child(StringConstants.recent_Message).setValue(messageId)
            completion(true)
        }
    }
    
    //MARK: - Send Images Function
    
    func sendImagesInChat(recieverName: String, recieverProfilePhoto: String, image: UIImage, recieverId: String, senderId: String, timestamp: String, completion: @escaping (Bool) -> Void) {
        let imageName = NSUUID().uuidString
        guard let imagedata = image.jpegData(compressionQuality: 0.2) else {
            print(FirebaseError.ErrorGettingImageData)
            return
        }
        storage.child(StringConstants.messageImages).child(imageName).putData(imagedata, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print(FirebaseError.ErrorUploadingImageURL)
                return
            }
            self.storage.child(StringConstants.messageImages).child(imageName).downloadURL { url, error in
                guard let imageURL = url, error == nil else {
                    print(FirebaseError.ErrorDownloadingImageURL)
                    return
                }
                let values = [StringConstants.imageURL: imageURL.absoluteString, StringConstants.recieverId: recieverId, StringConstants.senderId: senderId, StringConstants.timestamp: timestamp, "message": "Sent a Image."] as [String : Any]
                let ref = self.database.child(StringConstants.messages)
                let childRef = ref.childByAutoId()
                childRef.updateChildValues(values) { [weak self] error, ref in
                    guard error == nil else {
                        print(FirebaseError.FailedToSendMessage)
                        completion(false)
                        return
                    }
                    guard let messageId = childRef.key else { return }
                    self?.database.child(StringConstants.userMessages).child(senderId).child(recieverId).updateChildValues([messageId: "1"])
                    self?.database.child(StringConstants.userMessages).child(recieverId).child(senderId).updateChildValues([messageId: "1"])
                    self?.database.child(StringConstants.userMessages).child(senderId).child(recieverId).child(StringConstants.recent_Message).setValue(messageId)
                    self?.database.child(StringConstants.userMessages).child(recieverId).child(senderId).child(StringConstants.recent_Message).setValue(messageId)
                    completion(true)
                }
            }
        }
    }
    
    //MARK: - Send Videos Function
    
    func getThumbnailImageURl(image: UIImage, completion: @escaping (_ imageURL: String) -> Void) {
        let imageName = NSUUID().uuidString
        guard let imagedata = image.jpegData(compressionQuality: 0.2) else {
            print(FirebaseError.ErrorGettingImageData)
            return
        }
        storage.child(StringConstants.thumbnailImages).child(imageName).putData(imagedata, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print(FirebaseError.ErrorDownloadingImageURL)
                return
            }
            self.storage.child(StringConstants.thumbnailImages).child(imageName).downloadURL { url, error in
                guard let imageURL = url, error == nil else {
                    print(FirebaseError.ErrorDownloadingImageURL)
                    return
                }
                print(imageURL.absoluteString)
                completion(imageURL.absoluteString)
            }
        }
    }
    
    func sendVideosInChat(videoURL: URL, imageURL: String, recieverId: String, senderId: String, timestamp: String, completion: @escaping (Bool) -> Void) {
        let videoName = NSUUID().uuidString
        storage.child(StringConstants.messageVideos).child(videoName).putFile(from: videoURL, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print(FirebaseError.ErrorUploadingVideo)
                return
            }
            print("Video saved to db successfully")
            self.storage.child(StringConstants.messageVideos).child(videoName).downloadURL { url, error in
                guard let videoDownloadURL = url, error == nil else {
                    print(FirebaseError.ErrorDownloadingVideoURL)
                    return
                }
                print(videoDownloadURL)
                
                let values = [StringConstants.videoURL: videoDownloadURL.absoluteString, StringConstants.imageURL: imageURL, StringConstants.recieverId: recieverId, StringConstants.senderId: senderId, StringConstants.timestamp: timestamp] as [String : Any]
                let ref = self.database.child(StringConstants.messages)
                let childRef = ref.childByAutoId()
                childRef.updateChildValues(values) { [weak self] error, ref in
                    guard error == nil else {
                        print(FirebaseError.FailedToSendMessage)
                        completion(false)
                        return
                    }
                    guard let messageId = childRef.key else { return }
                    self?.database.child(StringConstants.userMessages).child(senderId).child(recieverId).updateChildValues([messageId: "1"])
                    self?.database.child(StringConstants.userMessages).child(recieverId).child(senderId).updateChildValues([messageId: "1"])
                    self?.database.child(StringConstants.userMessages).child(senderId).child(recieverId).child(StringConstants.recent_Message).setValue(messageId)
                    self?.database.child(StringConstants.userMessages).child(recieverId).child(senderId).child(StringConstants.recent_Message).setValue(messageId)
                    completion(true)
                }
            }
        }
    }
    
    //MARK: - Fetch All Messages In MessageLogController
    
    func observePerticularMessage(for userWithID: String, completion: @escaping ([Message]) -> Void) {
        var messages = [Message]()
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        database.child(StringConstants.userMessages).child(uid).child(userWithID).observe(.childAdded) { [weak self] snapShot in
            let messageID = snapShot.key
            self?.database.child(StringConstants.messages).child(messageID).observeSingleEvent(of: .value) { dataSnapshot in
                guard let dictionary = dataSnapshot.value as? [String: Any] else { return }
                let message = Message(dictionary: dictionary)
                messages.append(message)
                completion(messages)
            }
        }
    }
    
    //MARK: - Status ViewController Functions
    
    func uploadStatusImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        let imageName = NSUUID().uuidString
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        guard let imagedata = image.jpegData(compressionQuality: 0.2) else {
            print(FirebaseError.ErrorGettingImageData)
            return
        }
        
        storage.child("status").child(imageName).putData(imagedata, metadata: nil) { storageMetadata, error in
            guard error == nil else {
                print(FirebaseError.ErrorUploadingImageURL)
                completion(false)
                return
            }
            self.storage.child("status").child(imageName).downloadURL { url, error in
                guard let imageURL = url?.absoluteString, error == nil else {
                    print(FirebaseError.ErrorDownloadingImageURL)
                    completion(false)
                    return
                }
                let values = ["imageURL": imageURL] as [String : Any]
                self.database.child("latestStatus").child(uid).updateChildValues(values)
                self.database.child("status").child(uid).childByAutoId().updateChildValues(values) { error, ref in
                    guard error == nil else {
                        print("Error Storing data in database")
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    func fetchUserStatus(user: String, completion: @escaping ([String]) -> Void) {
        var imageArray = [String]()
        database.child("status").observeSingleEvent(of: .childAdded) { snapShot in
            self.database.child("status").child(user).observe(.childAdded) { snapshot in
                self.database.child("status").child(user).child(snapshot.key).observe(.value) { dataSnapShot in
                    if let dictionary = dataSnapShot.value as? [String: Any] {
                        guard let imageURL = dictionary["imageURL"] as? String else { return }
                        imageArray.append(imageURL)
                        completion(imageArray)
                    }
                }
            }
        }
    }
    
    func fetchLatestUserStatus(completion: @escaping ([Status]) -> Void) {
        var statusArray = [Status]()
        database.child("latestStatus").observe(.childAdded) { snapShot in
            let userID = snapShot.key
            self.database.child("latestStatus").child(userID).observe(.value) { snapshot in
                if let dictionary = snapshot.value as? [String: Any] {
                    guard let imageURL = dictionary["imageURL"] as? String else { return }
                    FirebaseManager.shared.fetchPerticularUser(id: userID) { userDictionary in
                        let user = Users(dictionary: userDictionary)
                        let status = Status(user: user, imageURL: imageURL)
                        statusArray.append(status)
                        completion(statusArray)
                    }
                }
            }
        }
    }
}

