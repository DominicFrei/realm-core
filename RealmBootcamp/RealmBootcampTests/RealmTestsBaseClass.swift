//
//  RealmTestsBaseClass.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 23/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

class RealmTestsBaseClass: XCTestCase {
    
    override func setUp() {
        realm_clear_last_error()
    }
    
    override func tearDown() {
        printLastError()
    }
    
    func printLastError() {
        var error = realm_error_t()
        let errorFound = realm_get_last_error(&error)
        XCTAssertFalse(errorFound)
        if let data = error.message.data {
            XCTFail("=== REALM LAST ERROR === \(String(cString: data))")
        }
    }

}
