//
//  C-API-Tests.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 21/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

class CApiTests: XCTestCase {
    
    var success = false
    
    override func setUp() {
        realm_clear_last_error()
    }
    
    override class func tearDown() {
        var error = realm_error_t()
        let errorFound = realm_get_last_error(&error)
        XCTAssertFalse(errorFound)
        if let data = error.message.data {
            XCTFail("\(String(cString: data))")
        }
    }
    
    func testFoo() {
        var foo = Foo()
        foo.x = 42
        let realm = Realm(classes: [foo.self])!
        
        // Create:
        realm.add(foo)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: foo, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys)
        
        // Delete:
        realm.delete(retrievedObject!, of: foo)
    }
    
    func testBar() {
        var bar = Bar()
        bar.x = 42
        let realm = Realm(classes: [bar.self])!
        
        // Create:
        realm.add(bar)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: bar, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys)
        
        // Delete:
        realm.delete(retrievedObject!, of: bar)
    }
    
    func testBaz() {
        var baz = Baz()
        baz.x = 42
        let realm = Realm(classes: [baz.self])!
        
        // Create:
        realm.add(baz)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: baz, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys)
        
        // Delete:
        realm.delete(retrievedObject!, of: baz)
    }
    
    func testFaz() {
        var faz = Faz()
        faz.x = 42
        let realm = Realm(classes: [faz.self])!
        
        // Create:
        realm.add(faz)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: faz, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys)
        
        // Delete:
        realm.delete(retrievedObject!, of: faz)
    }
    
}
