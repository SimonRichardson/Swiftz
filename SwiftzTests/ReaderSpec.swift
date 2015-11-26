//
//  ReaderSpec.swift
//  Swiftz
//
//  Created by Matthew Purland on 11/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Swiftz

class ReaderSpec : XCTestCase {
    func testReader() {
        func hello() -> Reader<String, String> {
            return Reader.init { "Hello \($0)" }
        }
        
        func bye() -> Reader<String, String> {
            return Reader.init { "Goodbye \($0)!" }
        }

        func helloAndGoodbye() -> Reader<String, String> {
            return Reader.init { hello().runReader($0) + " and " + bye().runReader($0) }
        }
        
        let input = "Matthew"
        let helloReader = hello()
        let modifiedHelloReader = helloReader.local({ "\($0) - Local"})
        XCTAssert(helloReader.runReader(input) == "Hello \(input)")
        XCTAssert(modifiedHelloReader.runReader(input) == "Hello \(input) - Local")
        
        let byeReader = bye()
        let modifiedByeReader = byeReader.local({ $0 + " - Local" })
        XCTAssert(byeReader.runReader(input) == "Goodbye \(input)!")
        XCTAssert(modifiedByeReader.runReader(input) == "Goodbye \(input) - Local!")
        
        let result = hello() >>- { $0.runReader(input) }
        XCTAssert(result == "Hello \(input)")
        
        let result2 = bye().runReader(input)
        XCTAssert(result2 == "Goodbye \(input)!")
        
        let helloAndGoodbyeReader = helloAndGoodbye()
        XCTAssert(helloAndGoodbyeReader.runReader(input) == "Hello \(input) and Goodbye \(input)!")
    }
}
