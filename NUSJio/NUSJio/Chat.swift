//
//  Chat.swift
//  NUSJio
//
//  Created by 程及雨晴 on 25/7/20.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation

class Chat {
    var otherUserID: String;
    var messages: [Message] = [];
    var chatID: String;
    init (newChatWith userID: String, chatID: String) {
        otherUserID = userID;
        self.chatID = chatID;
    }
}
