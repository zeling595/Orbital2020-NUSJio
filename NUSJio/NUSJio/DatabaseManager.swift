//
//  DatabaseManager.swift
//  NUSJio
//
//  Created by 程及雨晴 on 24/7/20.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
}
