//
//  CreateObjectTests.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 22/12/2020.
//

import XCTest
@testable import RealmBootcamp

class CreateObjectTests: XCTestCase {
    
    func test() {
        let game = Game(releaseYear: 2016)
        XCTAssertEqual(game.properties().count, 1)
        XCTAssertEqual(game.properties()[0].label, "releaseYear")
        XCTAssert(game.properties()[0].value is Int)
        XCTAssertEqual(game.properties()[0].value as? Int, 2016)
        
        game.persist()
    }
    
}
