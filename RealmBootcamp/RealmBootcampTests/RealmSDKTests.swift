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
    // swiftlint:disable cyclomatic_complexity
    func testFoo() {
        let initialPrimaryKey = 42
        let foo = Foo(x: initialPrimaryKey, y: 0, z: 0)
        var realm: Realm!
        do {
            realm = try Realm()
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        create(foo, in: realm)
        
        // Read:
        var (retrievedObject, outColumnKeys, object): (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>?, Foo?)
        do {
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: foo, withPrimaryKey: initialPrimaryKey)
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
        
        XCTAssertEqual(unwrappedObject.x, initialPrimaryKey)
        XCTAssertEqual(unwrappedObject.y, 0)
        XCTAssertEqual(unwrappedObject.z, 0)
        
        do {
            // Update:
            try realm.write {
                // TODO: Use realm_get_class_properties
                let success = try realm.updateValues(for: unwrappedRetrievedObject, propertyKeys: unwrappedOutColumnKeys, newValues: [initialPrimaryKey, 24, 25])
                XCTAssert(success)
            }
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        do {
            // Read again:
            // TODO: Finding the object with the new key should be possible. -> Bug somewhere that needs to be found.
            // TODO: Changing the primary key should not be possible though and needs to be forbidden.
            (retrievedObject, outColumnKeys, object) = try realm.find(testClass: foo, withPrimaryKey: initialPrimaryKey)
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        guard retrievedObject != nil else {
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
        
        XCTAssertEqual(unwrappedObjectAfterUpdate.x, initialPrimaryKey)
        XCTAssertEqual(unwrappedObjectAfterUpdate.y, 24)
        XCTAssertEqual(unwrappedObjectAfterUpdate.z, 25)
        
        // Delete:
        do {
            try realm.write({
                //                let success = realm.delete(unwrappedRetrievedObjectAfterUpdate, of: foo)
                //                XCTAssert(success)
            })
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func create<T: Persistable>(_ object: T, in realm: Realm) {
        do {
            try realm.write {
                try realm.add(object)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
}
