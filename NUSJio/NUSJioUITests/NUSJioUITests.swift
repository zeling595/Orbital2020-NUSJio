//
//  NUSJioUITests.swift
//  NUSJioUITests
//
//  Created by Zeling Long on 2020/5/30.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import XCTest

class NUSJioUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testValidLoginSuccess() {
        
        let validEmail = "e1122335@u.nus.edu"
        let validPassword = "12345678"
        
        let emailTextField = app.textFields["NUSNET ID"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.tap()
        emailTextField.typeText(validEmail)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(validPassword)
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Sign In"]/*[[".buttons[\"Sign In\"].staticTexts[\"Sign In\"]",".staticTexts[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tabBarButton = app.tabBars.buttons["Activities"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBarButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testJoinButton() {
        let validEmail = "e1122335@u.nus.edu"
        let validPassword = "12345678"
        
        let emailTextField = app.textFields["NUSNET ID"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.tap()
        emailTextField.typeText(validEmail)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(validPassword)
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Sign In"]/*[[".buttons[\"Sign In\"].staticTexts[\"Sign In\"]",".staticTexts[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tabBarButton = app.tabBars.buttons["Activities"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBarButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        let exploreTabBarButton = app.tabBars.buttons["Explore"]
        XCTAssertTrue(exploreTabBarButton.exists)
        exploreTabBarButton.tap()
        
        let jazzConcertCell = app.tables/*@START_MENU_TOKEN@*/.staticTexts["Nus jazz band concert"]/*[[".cells.staticTexts[\"Nus jazz band concert\"]",".staticTexts[\"Nus jazz band concert\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: jazzConcertCell, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        jazzConcertCell.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let likeButton = elementsQuery.buttons["Like"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: likeButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        likeButton.tap()
        
        let unlikeButton = elementsQuery.buttons["Unlike"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: unlikeButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        unlikeButton.tap()
        
        let joinButton = elementsQuery.buttons["Join"]
        XCTAssertTrue(joinButton.exists)
        joinButton.tap()
        
        app.navigationBars["NUSJio.ExploreDetailView"].buttons["Explore"].tap()
    }
    
    
    func testJioButton() {
        let validEmail = "e1122335@u.nus.edu"
        let validPassword = "12345678"
        
        let emailTextField = app.textFields["NUSNET ID"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.tap()
        emailTextField.typeText(validEmail)
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(validPassword)
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Sign In"]/*[[".buttons[\"Sign In\"].staticTexts[\"Sign In\"]",".staticTexts[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tabBarButton = app.tabBars.buttons["Activities"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBarButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        let element = app.tables.children(matching: .cell).element(boundBy: 0).children(matching: .other).element(boundBy: 1)
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        element.forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let jioButton = elementsQuery.buttons["Jio"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: jioButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        jioButton.tap()
        
        app.alerts["Finalise Jio"].scrollViews.otherElements.buttons["OK"].tap()
        let completeButton = elementsQuery.buttons["Complete"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: completeButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        completeButton.tap()
        app.alerts["Complete Jio"].scrollViews.otherElements.buttons["OK"].tap()
    }
}

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}
