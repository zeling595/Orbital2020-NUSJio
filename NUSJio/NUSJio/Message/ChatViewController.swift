//
//  ChatViewController.swift
//  NUSJio
//
//  Created by 程及雨晴 on 25/7/20.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView


struct Sender: SenderType, Equatable {
    //var user : User
    var photoURL: String;
    var senderId: String
    var displayName: String
    
    init(user: User) {
        photoURL = user.profilePictureURLStr!
        senderId = user.uuid
        displayName = user.username
    }
    
    init(url: String, id: String, name: String) {
        photoURL = url;
        senderId = id;
        displayName = name;
    }
    
    
}

struct Message: MessageType, Equatable {
    var sender: SenderType
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.sender.senderId == rhs.sender.senderId && lhs.messageId == rhs.messageId
    }
    
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
      
}

class ChatViewController: MessagesViewController,InputBarAccessoryViewDelegate {
    
    
    private let db = Firestore.firestore()
    
    //public var completion: (([String: String]) -> Void)?
    var messages :[Message] = [];
    var otherUserID : String!
    var currentUserID: String!
    let dataController = DataController()
    var chatID:String!
    
    //not in use
    var currentUserSender: Sender!
    var otherUserSender: Sender!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        dataController.fetchUser(userId: currentUserID) { (user) in
            if let user = user {
                let currentUser = user
                self.currentUserSender = Sender(user: currentUser)
            }
            self.dataController.fetchUser(userId: self.otherUserID) { (user) in
                if let user = user {
                    let otherUser = user
                    self.otherUserSender = Sender(user: otherUser)
                    self.title = self.otherUserSender.displayName
                    
                }
            }
            
            self.dataController.fetchMessageForChat(chatID: self.chatID) { (messages) in
                if let messages = messages {
                    for msg in messages {
                        self.insertNewMessage(msg)
                        self.messagesCollectionView.reloadData()
                        print("chat with user: \(msg.kind)")
                    }
                    //self.messages = messages;
                    
                    self.messagesCollectionView.reloadData()
                }
            }
        }
        
        
        
        
        super.viewWillAppear(animated)

    }
    
    
    override func viewDidLoad() {
        dataController.fetchUser(userId: currentUserID) { (user) in
            if let user = user {
                let currentUser = user
                self.currentUserSender = Sender(user: currentUser)
            }
            self.dataController.fetchUser(userId: self.otherUserID) { (user) in
                if let user = user {
                    let otherUser = user
                    self.otherUserSender = Sender(user: otherUser)
                    self.title = self.otherUserSender.displayName
                }
            }
            
            self.dataController.fetchMessageForChat(chatID: self.chatID) { (messages) in
                if let messages = messages {
                    for msg in messages {
                        self.insertNewMessage(msg)
                        self.messagesCollectionView.reloadData()
                        print("chat with user: \(msg.kind)")
                    }
                    self.messages = messages;
                    
                    self.messagesCollectionView.reloadData()
                }
                self.messages.append(Message(sender: Sender(url: "", id: "otherUser", name: "Rachel"),messageId: "2", sentDate: Date(), kind: .text("Sure! I am looking for ppl interested in volleyball to play together haha. Wanna join us?")))
                self.messagesCollectionView.reloadData()
            } 
        }
    
    

        print(messages)
        
        super.viewDidLoad()
        
        //insertNewMessage(Message(sender: currentUser, messageId: "1", sentDate: Date(), kind: .text("Hello")))
        //insertNewMessage(Message(sender: otherUser,messageId: "2", sentDate: Date(), kind: .text("Hi, what's up")))

        
        
        
        maintainPositionOnKeyboardFrameChanged = true
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self;
        messagesCollectionView.messagesLayoutDelegate = self;
        messagesCollectionView.messagesDisplayDelegate = self;
        setupInputButton()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Helpers

    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.tintColor = Styles.themeOrange
        //button.onTouchUpInside { [weak self] _ in
          //  self?.presentInputActionSheet()
        //}
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        //messageInputBar.leftStackViewItems[0].self.color
        
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
        return
      }
      
      messages.append(message)
      //messages.sort()
      
        //let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
      //let shouldScrollToBottom = //messagesCollectionView.isAtBottom &&
        //isLatestMessage
      
      messagesCollectionView.reloadData()
      
      //if shouldScrollToBottom {
        //DispatchQueue.main.async {
          //self.messagesCollectionView.scrollToBottom(animated: true)
        //}
      //}
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print(text)
        let db = Firestore.firestore();
        let message = Message(sender: currentUserSender, messageId: "", sentDate: Date(), kind: .text(text))
        insertNewMessage(message)
        self.messagesCollectionView.reloadData()
        var ref: DocumentReference? = nil
        ref = db.collection("Message").addDocument(data: [
            "MessageID": "temporary",
            "senderID": message.sender.senderId,
            "text": text,
            "timeStamp": Date()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
            self.messagesCollectionView.scrollToBottom()
            print(text)
            //TODO: update messageid in firebase
        }
        db.collection("Message").document(ref!.documentID).setData([
            "MessageID": ref!.documentID,
            "senderID": message.sender.senderId,
            "text": text,
            "timeStamp": Date()
        ])
        db.collection("Chat").document(chatID).updateData([
            "threadOfMsgID": FieldValue.arrayUnion([ref!.documentID])
        ])

      inputBar.inputTextView.text = ""
    }
    

   

}


extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> Bool {

      return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(corner, .curved)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Styles.themeOrange : .lightGray
    }
    
    func currentSender() -> SenderType {
        return self.currentUserSender;
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}









