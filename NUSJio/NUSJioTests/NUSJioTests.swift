//
//  NUSJioTests.swift
//  NUSJioTests
//
//  Created by Zeling Long on 2020/5/30.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import XCTest
@testable import NUSJio

class NUSJioTests: XCTestCase {
    
    // log in
    func testEmailCheckingA() {
        let wrongEmail = "e1122@u.123.nus"
        let result = Utilities.isNUSEmailValid(wrongEmail)
        XCTAssert(!result)
    }
    
    func testEmailCheckingB() {
        let wrongEmail = "e1122334"
        let result = Utilities.isNUSEmailValid(wrongEmail)
        XCTAssert(!result)
    }
    
    func testEmailCheckingC() {
        let correctEmail = "e1122334@nus.edu.sg"
        let result = Utilities.isNUSEmailValid(correctEmail)
        XCTAssert(result)
    }
    
    func testCanJoinA() {
        let testUser = User(uuid: "1", username: "test", email: "123@123.com", password: "111111", profilePictureURLStr: nil, myActivityIds: ["1"], joinedActivityIds: [], likedActivityIds: [], schedule: [])
        let testActivity = Activity(uuid: "1", title: "test", description: nil, hostId: "1", participantIds: ["1","2","3"], participantsInfo: ["1":"1","2":"2","3":"3"], likedBy: [], location: nil, time: nil, state: .open, imageURLStr: "url", categories: nil, numOfParticipants: 3, gender: .mixed, faculties: [], selectedFacultiesBoolArray: [])
        let activityDetailVC = ActivityDetailViewController()
        activityDetailVC.currentUser = testUser
        activityDetailVC.activity = testActivity
        let result = activityDetailVC.canJoin()
        XCTAssertTrue(!result)
    }
    
    func testCanJoinB() {
        let testUser = User(uuid: "2", username: "test", email: "123@123.com", password: "111111", profilePictureURLStr: nil, myActivityIds: ["1"], joinedActivityIds: [], likedActivityIds: [], schedule: [])
        let testActivity = Activity(uuid: "1", title: "test", description: nil, hostId: "1", participantIds: [], participantsInfo: [:], likedBy: [], location: nil, time: nil, state: .open, imageURLStr: "url", categories: nil, numOfParticipants: 3, gender: .mixed, faculties: [], selectedFacultiesBoolArray: [])
        let activityDetailVC = ActivityDetailViewController()
        activityDetailVC.currentUser = testUser
        activityDetailVC.activity = testActivity
        let result = activityDetailVC.canJoin()
        XCTAssertTrue(result)
    }
    
    func testCanJoinC() {
        let testUser = User(uuid: "3", username: "test", email: "123@123.com", password: "111111", profilePictureURLStr: nil, myActivityIds: ["1"], joinedActivityIds: [], likedActivityIds: [], schedule: [])
        let testActivity = Activity(uuid: "1", title: "test", description: nil, hostId: "1", participantIds: ["1","2"], participantsInfo: ["1":"1","2":"2"] , likedBy: [], location: nil, time: nil, state: .open, imageURLStr: "url", categories: nil, numOfParticipants: 3, gender: .mixed, faculties: [], selectedFacultiesBoolArray: [])
        let activityDetailVC = ActivityDetailViewController()
        activityDetailVC.activity = testActivity
        activityDetailVC.currentUser = testUser
        let result = activityDetailVC.canJoin()
        XCTAssertTrue(result)
    }

}
