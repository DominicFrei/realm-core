//
//  RealmSDKTests.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 21/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

class RealmSDKTests: RealmTestsBaseClass {
    
    func testFoo() {
        let foo = Foo(x: 42, y: 0, z: 0)
        let realm = Realm(classes: [foo.self])!
        
        // Create:
        realm.add(foo)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: foo, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        XCTAssertEqual(object.y, 0)
        XCTAssertEqual(object.z, 0)
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys, newValues: [23, 24, 25])
        
        // Delete:
        realm.delete(retrievedObject!, of: foo)
    }
    
    func testBar() {
        let bar = Bar(x: 42, y: 0, z: 0)
        let realm = Realm(classes: [bar.self])!
        
        // Create:
        realm.add(bar)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: bar, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        XCTAssertEqual(object.y, 0)
        XCTAssertEqual(object.z, 0)
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys, newValues: [23, 24, 25])
        
        // Delete:
        realm.delete(retrievedObject!, of: bar)
    }
    
    func testBaz() {
        let baz = Baz(x: 42, y: 0, z: "0")
        let realm = Realm(classes: [baz.self])!
        
        // Create:
        realm.add(baz)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: baz, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        XCTAssertEqual(object.y, 0)
        XCTAssertEqual(object.z, "")
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys, newValues: [23, 24, "25"])
        
        // Delete:
        realm.delete(retrievedObject!, of: baz)
    }
    
    func testFaz() {
        let faz = Faz(x: 42, y: 0, z: 0, a: "", b: "")
        let realm = Realm(classes: [faz.self])!
        
        // Create:
        realm.add(faz)
        
        // Read:
        let (retrievedObject, outColumnKeys, object) = realm.find(testClass: faz, withPrimaryKey: 42)
        XCTAssertEqual(object.x, 42)
        XCTAssertEqual(object.y, 0)
        XCTAssertEqual(object.z, 0)
        XCTAssertEqual(object.a, "")
        XCTAssertEqual(object.b, "")
        
        // Update:
        realm.updateValues(for: retrievedObject!, propertyKeys: outColumnKeys, newValues: [23, 24, 25, "a", "b"])
        
        // Delete:
        realm.delete(retrievedObject!, of: faz)
    }
    
}
