//
//  MessagesTableViewController.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/10.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseAuth
import FirebaseFirestore

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var chatTable : UITableView!
    
    let dataController = DataController()
    var allChats : [Chat] = [];
    var displayedChats : [Chat] = [];
    var currentUser: User!
    
    //= User(uuid: "", username: "", email: "", password: "", profilePictureURLStr: "", myActivityIds: [], joinedActivityIds: [], likedActivityIds: [], schedule: [])
    
    
    
    private let spinner = JGProgressHUD(style: .dark)
    private let searchBar :UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for chat with user:"
        searchBar.tintColor = Styles.themeOrange
        return searchBar
    }()
    private let noConversationLabel : UILabel = {
       let label = UILabel()
        label.text = "You don't have any conversations yet \n Go to explore to find more activities!"
        label.textAlignment = .center
        label.textColor = Styles.themeOrange
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = false;
        return label
    }()
    private let noChatFoundLabel : UILabel = {
                let label = UILabel()
                label.text = "No chat found :("
                label.textAlignment = .center
                label.textColor = Styles.themeOrange
                label.font = .systemFont(ofSize: 21, weight: .medium)
                label.isHidden = true;
                return label
        
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            // print("(print from my activities) uuid \(uuid)")
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                } else {
                    print("oops cannot fetch user")
                }
                //load conversation
                //fetchConversations();
                self.dataController.fetchChatsForUser (userId: self.currentUser.uuid){(chats) in
                    if let chats = chats{
                        print(chats)
                        self.allChats = chats
                        if self.allChats.count != 0 {
                            self.chatTable.isHidden = false;
                            self.noConversationLabel.isHidden = true;
                        }
                        self.chatTable.reloadData()
                    } else {
                        print("error fetching all chats")
                    }

                }
                
            }
        } else {
            print("oops no current user")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(chatTable)
        view.addSubview(noConversationLabel)
        chatTable.isHidden = true;
        noConversationLabel.isHidden = false;
        setUpTableView()
        chatTable.keyboardDismissMode = .onDrag
        //load currentUser
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            // print("(print from my activities) uuid \(uuid)")
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                } else {
                    print("oops cannot fetch user")
                }
                //load conversation
                //fetchConversations();
                self.dataController.fetchChatsForUser (userId: self.currentUser.uuid){(chats) in
                    if let chats = chats{
                        print(chats)
                        self.allChats = chats
                        if self.allChats.count != 0 {
                            self.chatTable.isHidden = false;
                            self.noConversationLabel.isHidden = true;
                        }
                        self.chatTable.reloadData()
                    } else {
                        print("error fetching all chats")
                    }

                }
                
            }
        } else {
            print("oops no current user")
        }
        
        
        
        
        //print("currentid: \(self.currentUser.uuid)")
        //print("no. of allChats: \(self.allChats.count)")
        
        //search bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearchButton))
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        
        
        
        
        
        //displayedChats = allChats;
        
        //print("currentid: \(currentUser.uuid)")
        //print("otherid: \(self.allChats[0].otherUserID)")
    }
    
    @objc private func didTapSearchButton(){
        //let navVC = UINavigationController(rootViewController: <#T##UIViewController#>)
        //implement search function
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chatTable.frame = view.bounds;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allChats.count;
    }
    
    func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTable.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        dataController.fetchUser(userId: allChats[indexPath.row].otherUserID) { (user) in
            if let user = user {
                var otherUser: User;
                otherUser = user
                cell.textLabel?.text = otherUser.username
                cell.accessoryType = .disclosureIndicator;
                //return cell;
                }
            }
        self.updateCellUI(cell: cell, userId: allChats[indexPath.row].otherUserID)
        
        
        
        return cell;
    }
    
    var username:String!
    func updateCellUI(cell: UITableViewCell, userId: String) {
        
        
        dataController.fetchUser(userId: userId) { (user) in
            
            self.username = user!.username
            cell.textLabel?.text = self.username
            self.chatTable.reloadData()
            
        }
    }
    
   /*
    func tableView (_tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let firebaseUser = Auth.auth().currentUser {
            let uuid = firebaseUser.uid
            dataController.fetchUser(userId: uuid) { (user) in
                if let user = user {
                    self.currentUser = user
                }
            }
        } else {
            print("oops no current user")
        }
        
        chatTable.deselectRow(at: indexPath, animated: true)
        let chat = displayedChats[indexPath.row]
        
        //TODO: modify to show correct message
        let vc = ChatViewController()
        //vc.currentUser = self.currentUser
        vc.currentUserID = currentUser.uuid
        vc.otherUserID = chat.otherUserID
        vc.title = chat.otherUserID
        self.navigationController!.pushViewController(vc, animated: true)
    }*/
    
    private func setUpTableView (){
        chatTable.delegate = self
        chatTable.dataSource = self
    }
    
    //TODO: implement this!
    func fetchConversations() {
        dataController.fetchChatsForUser(userId: currentUser.uuid) { (chats) in
            if let chats = chats {
                self.allChats = chats
            }
        }
        print("no. of chats: \(allChats.count)")
        
        
        
        if allChats.count != 0 {
            chatTable.isHidden = false;
            noConversationLabel.isHidden = true;
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if segue.identifier == "messageToChatSegue",
                let chatViewController = segue.destination as? ChatViewController {
                let indexPath = chatTable.indexPathForSelectedRow!
            var selectedChat : Chat;
            
                selectedChat = allChats[indexPath.row]
            
            chatViewController.currentUserID = self.currentUser.uuid
            chatViewController.otherUserID = selectedChat.otherUserID
            chatViewController.chatID = selectedChat.chatID

            }
    
        }
    
    
    
    
    
    
    

    

}
