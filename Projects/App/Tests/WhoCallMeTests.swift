//
//  WhoCallMeTests.swift
//  WhoCallMeTests
//
//  Created by 영준 이 on 2016. 3. 10..
//  Copyright © 2016년 leesam. All rights reserved.
//

import XCTest
@testable import App

class WhoCallMeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    // MARK: - Convert All ad-gating counter

    func testConvertAllCountGating() {
        let key = LSDefaults.Keys.ConvertAllCount
        let saved = LSDefaults.Defaults.object(forKey: key)
        defer {
            if let saved {
                LSDefaults.Defaults.set(saved, forKey: key)
            } else {
                LSDefaults.Defaults.removeObject(forKey: key)
            }
        }

        LSDefaults.ConvertAllCount = 0
        // First Convert All ever is free.
        XCTAssertEqual(LSDefaults.ConvertAllCount, 0)

        LSDefaults.increaseConvertAllCount()
        // Second and every subsequent run is ad-gated.
        XCTAssertEqual(LSDefaults.ConvertAllCount, 1)

        LSDefaults.increaseConvertAllCount()
        XCTAssertEqual(LSDefaults.ConvertAllCount, 2)
    }
    
    // MARK: - Fire-and-forget interstitial

    /// `showInterstitial` must be a safe no-op before `setup()` has wired a
    /// `GADManager` — the `gadManager?` optional-chain should simply do nothing.
    @MainActor
    func testShowInterstitialDoesNotThrowWhenUnprepared() {
        let manager = SwiftUIAdManager()
        manager.showInterstitial(unit: .full)
        // No crash, no GADManager touched — reaching here is the assertion.
        XCTAssertFalse(manager.isReady)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
