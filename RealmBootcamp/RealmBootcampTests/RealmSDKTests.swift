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
    
    // swiftlint:disable function_body_length
    func testFoo() {
        let foo = Foo(x: 42, y: 0, z: 0)
        let realm = Realm(classes: [foo.self])!
        
        // Create:
        realm.add(foo)
        
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
        
        // Update:
        realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, 25])
        
        // Read again:
        do {
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
        realm.delete(unwrappedRetrievedObjectAfterUpdate, of: foo)
        
    }
    
    func testBar() {
        let bar = Bar(x: 42, y: 0, z: 0)
        let realm = Realm(classes: [bar.self])!
        
        // Create:
        realm.add(bar)
        
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
        
        // Update:
        realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, 25])
        
        // Read again:
        do {
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
        realm.delete(unwrappedRetrievedObjectAfterUpdate, of: bar)
    }
    
    func testBaz() {
        let baz = Baz(x: 42, y: 0, z: "0")
        let realm = Realm(classes: [baz.self])!
        
        // Create:
        realm.add(baz)
        
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
        
        // Update:
        realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, "25"])
        
        // Read again:
        do {
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
        realm.delete(unwrappedRetrievedObjectAfterUpdate, of: baz)
    }
    
    func testFaz() {
        let faz = Faz(x: 42, y: 0, z: 0, a: "", b: "")
        let realm = Realm(classes: [faz.self])!
        
        // Create:
        realm.add(faz)
        
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
        
        // Update:
        realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [42, 24, 25, "a", "b"])
        
        // Read again:
        do {
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
        realm.delete(unwrappedRetrievedObjectAfterUpdate, of: faz)
    }
    
    //     Due Date: 11 / 01 / 2021
    //        func testJason() {
    //            let faz = Faz(x: 42, y: 0, z: 0, a: "a", b: "b")
    //            var realm = Realm()
    //            XCTAssertThrows(realm.add(faz))
    //            realm.write {
    //                realm.add(faz)
    //                faz.a = "foo"
    //                faz.y = 84
    //            }
    //            XCTAssertTrue(faz.isValid)
    //            let foundObj = realm.object<MyObject>(primaryKey: 84)
    //            XCTAssertEqual(foundObj, faz)
    //            XCTAssertTrue(foundObj.isValid)
    //            XCTAssertEqual(foundObj.str, "foo")
    //            XCTAssertEqual(foundObj.int, 84)
    //            XCTAssertThrows(() { foundObj.y = 42})
    //            XCTAssertThrows(realm.delete(foundObj))
    //            realm.write {
    //                realm.delete(foundObj)
    //            }
    //            XCAssertFalse(foundObj.isValid)
    //        }
    
}
