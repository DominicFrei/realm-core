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
        
        let foo2primaryKey = 42
        let foo2 = Foo()
        foo2.x = foo2primaryKey
        foo2.y = 1
        foo2.z = 2
        
        // Open Realm:
        guard let realm = openRealm() else {
            XCTFail("Could not open realm.")
            return
        }
        
        // Create:
        do {
            try realm.write {
                try realm.add(foo2)
            }
        } catch let error {
            XCTFail(String(describing: error))
        }
        
        // Read:
        do {
            let object = try realm.find(Foo.self, withPrimaryKey: foo2primaryKey)
            XCTAssertEqual(object.x, foo2primaryKey)
            XCTAssertEqual(object.y, 1)
            XCTAssertEqual(object.z, 2)
        } catch let error {
            XCTFail(String(describing: error))
        }
        
        // Update:
        do {
            try realm.write {
                foo2.y = 23
                foo2.z = 24
            }
            let object = try realm.find(Foo.self, withPrimaryKey: foo2primaryKey)
            XCTAssertEqual(object.x, foo2primaryKey)
            XCTAssertEqual(object.y, 23)
            XCTAssertEqual(object.z, 24)
        } catch let error {
            XCTFail(String(describing: error))
        }
        
        // Delete:
        delete(foo2, withPrimaryKey: foo2primaryKey, from: realm)
    }
    
    func openRealm() -> Realm? {
        do {
            return try Realm()
        } catch let error {
            XCTFail(String(describing: error))
            return nil
        }
    }
    
    func create<T: Persistable>(_ object: T, in realm: Realm) {
        do {
            try realm.write {
                try realm.add(object)
            }
        } catch let error {
            XCTFail(String(describing: error))
        }
    }
    
    func delete<T: Persistable>(_ object: T, withPrimaryKey primaryKey: Int, from realm: Realm) {
        do {
            try realm.write({
                try realm.delete(object)
            })
        } catch let error {
            XCTFail(String(describing: error))
        }
    }
    
}
