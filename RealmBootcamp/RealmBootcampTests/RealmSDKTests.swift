//
//  RealmSDKTests.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 21/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

// swiftlint:disable type_body_length
class RealmSDKTests: RealmTestsBaseClass {
    
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func testFoo() {
        let foo = Foo(x: 42, y: 0, z: 0)
        let realm = Realm(classes: [foo.self])!
        
        // Create:
        do {
            try realm.write {
                try realm.add(foo)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Read:
        var (retrievedObject, outColumnKeys, object): (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>?, Foo?)
        do {
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: foo, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObject = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard let unwrappedOutColumnKeys = outColumnKeys else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObject = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObject.x, 42)
        XCTAssertEqual(unwrappedObject.y, 0)
        XCTAssertEqual(unwrappedObject.z, 0)
        
        do {
            // Update:
            try realm.write {
                let success = try realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, 25])
                XCTAssert(success)
            }
            
            // Read again:
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: foo, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObjectAfterUpdate = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard outColumnKeys != nil else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObjectAfterUpdate = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObjectAfterUpdate.x, 42)
        XCTAssertEqual(unwrappedObjectAfterUpdate.y, 24)
        XCTAssertEqual(unwrappedObjectAfterUpdate.z, 25)
        
        // Delete:
        do {
            try realm.write({
                let success = realm.delete(unwrappedRetrievedObjectAfterUpdate, of: foo)
                XCTAssert(success)
            })
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testBar() {
        let bar = Bar(x: 42, y: 0, z: 0)
        let realm = Realm(classes: [bar.self])!
        
        // Create:
        do {
            try realm.write {
                try realm.add(bar)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Read:
        var (retrievedObject, outColumnKeys, object): (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>?, Bar?)
        do {
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: bar, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObject = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard let unwrappedOutColumnKeys = outColumnKeys else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObject = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObject.x, 42)
        XCTAssertEqual(unwrappedObject.y, 0)
        XCTAssertEqual(unwrappedObject.z, 0)
        
        do {
            // Update:
            try realm.write {
                let success = try realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, 25])
                XCTAssert(success)
            }
            
            // Read again:
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: bar, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObjectAfterUpdate = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard outColumnKeys != nil else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObjectAfterUpdate = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObjectAfterUpdate.x, 42)
        XCTAssertEqual(unwrappedObjectAfterUpdate.y, 24)
        XCTAssertEqual(unwrappedObjectAfterUpdate.z, 25)
        
        // Delete:
        do {
            try realm.write({
                let success = realm.delete(unwrappedRetrievedObjectAfterUpdate, of: bar)
                XCTAssert(success)
            })
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testBaz() {
        let baz = Baz(x: 42, y: 0, z: "0")
        let realm = Realm(classes: [baz.self])!
        
        // Create:
        do {
            try realm.write {
                try realm.add(baz)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Read:
        var (retrievedObject, outColumnKeys, object): (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>?, Baz?)
        do {
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: baz, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObject = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard let unwrappedOutColumnKeys = outColumnKeys else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObject = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObject.x, 42)
        XCTAssertEqual(unwrappedObject.y, 0)
        XCTAssertEqual(unwrappedObject.z, "")
        
        do {
            // Update:
            try realm.write {
                let success = try realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, "25"])
                XCTAssert(success)
            }
            
            // Read again:
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: baz, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObjectAfterUpdate = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard outColumnKeys != nil else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObjectAfterUpdate = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObjectAfterUpdate.x, 42)
        XCTAssertEqual(unwrappedObjectAfterUpdate.y, 24)
        XCTAssertEqual(unwrappedObjectAfterUpdate.z, "25")
        
        // Delete:
        do {
            try realm.write({
                let success = realm.delete(unwrappedRetrievedObjectAfterUpdate, of: baz)
                XCTAssert(success)
            })
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testFaz() {
        let faz = Faz(x: 42, y: 0, z: 0, a: "", b: "")
        let realm = Realm(classes: [faz.self])!
        
        // Create:
        do {
            try realm.write {
                try realm.add(faz)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Read:
        var (retrievedObject, outColumnKeys, object): (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>?, Faz?)
        do {
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: faz, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObject = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard let unwrappedOutColumnKeys = outColumnKeys else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObject = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObject.x, 42)
        XCTAssertEqual(unwrappedObject.y, 0)
        XCTAssertEqual(unwrappedObject.z, 0)
        
        do {
            // Update:
            try realm.write {
                let success = try realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, 25, "a", "b"])
                XCTAssert(success)
            }
            
            // Read again:
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: faz, withPrimaryKey: 42)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard let unwrappedRetrievedObjectAfterUpdate = retrievedObject else {
            XCTFail("retrievedObject must not be nil.")
            return
        }
        guard outColumnKeys != nil else {
            XCTFail("outColumnKeys must not be nil.")
            return
        }
        guard let unwrappedObjectAfterUpdate = object else {
            XCTFail("object must not be nil.")
            return
        }
        
        XCTAssertEqual(unwrappedObjectAfterUpdate.x, 42)
        XCTAssertEqual(unwrappedObjectAfterUpdate.y, 24)
        XCTAssertEqual(unwrappedObjectAfterUpdate.z, 25)
        XCTAssertEqual(unwrappedObjectAfterUpdate.a, "a")
        XCTAssertEqual(unwrappedObjectAfterUpdate.b, "b")
        
        // Delete:
        do {
            try realm.write({
                let success = realm.delete(unwrappedRetrievedObjectAfterUpdate, of: faz)
                XCTAssert(success)
            })
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
