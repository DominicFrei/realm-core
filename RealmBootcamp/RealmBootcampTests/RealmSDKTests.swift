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
        
        let fazPrimaryKey = 42
        let faz = Faz(x: fazPrimaryKey, y: 0, z: 0, a: "", b: "")
        
        // Open Realm:
        guard let realm = openRealm() else {
            XCTFail("Could not open realm.")
            return
        }
        
        // Create:
        create(faz, in: realm)
        
        // Read:
        do {
            let object = try realm.find(objectOfType: faz, withPrimaryKey: fazPrimaryKey)
            XCTAssertEqual(object.x, fazPrimaryKey)
            XCTAssertEqual(object.y, 0)
            XCTAssertEqual(object.z, 0)
            XCTAssertEqual(object.a, "")
            XCTAssertEqual(object.b, "")
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        // Update:
        do {
            try realm.write {
                try realm.updateValues(objectOfType: faz, withPrimaryKey: fazPrimaryKey, newValues: [fazPrimaryKey, 24, 25, "a", "b"])
            }
            // TODO: Finding the object with the new key should be possible. -> Bug somewhere that needs to be found.
            // TODO: Changing the primary key should not be possible though and needs to be forbidden.
            let object = try realm.find(objectOfType: faz, withPrimaryKey: fazPrimaryKey)
            XCTAssertEqual(object.x, fazPrimaryKey)
            XCTAssertEqual(object.y, 24)
            XCTAssertEqual(object.z, 25)
            XCTAssertEqual(object.a, "a")
            XCTAssertEqual(object.b, "b")
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
        // Add more objects:
        let faz2 = Faz(x: 43, y: 1, z: 2, a: "3", b: "4")
        let foo = Foo(x: 44, y: 1, z: 2)
        let bar = Bar(x: 45, y: 46, z: 47)
        create(faz2, in: realm)
        create(foo, in: realm)
        create(bar, in: realm)
        
        // Delete:
        delete(faz, withPrimaryKey: fazPrimaryKey, from: realm)
        
    }
    
    func openRealm() -> Realm? {
        do {
            return try Realm()
        } catch let error {
            XCTFail(error.localizedDescription)
            return nil
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
    
    func delete<T: Persistable>(_ object: T, withPrimaryKey primaryKey: Int, from realm: Realm) {
        do {
            try realm.write({
                try realm.delete(object, primaryKey: primaryKey)
            })
        } catch let error as RealmError {
            XCTFail(error.localizedDescription)
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
