//
//  JasonsTest.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 29/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

class JasonsTest: RealmTestsBaseClass {
    
    class MyObject: Persistable {
        @Persisted(isPrimaryKey: true) var int
        @PersistedString var str
    }
    
    func test() {
        let obj = MyObject()
        obj.int = 42
        var realm: Realm!
        do {
            realm = try Realm()
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        XCTAssertThrowsError(try realm.add(obj))
        do {
            try realm.write {
                try realm.add(obj)
                obj.str = "foo"
            }
            XCTAssertEqual(obj.str, "foo")
            XCTAssertTrue(obj.isValid())
            let foundObj = try realm.find(MyObject.self, withPrimaryKey: 42)
            XCTAssertEqual(foundObj, obj)
            XCTAssertTrue(foundObj.isValid())
            XCTAssertEqual(foundObj.str, "foo")
            XCTAssertEqual(foundObj.int, 42)
            XCTAssertThrowsError(foundObj.int = 84)
            XCTAssertThrowsError(try realm.delete(foundObj))
            try realm.write {
                try realm.delete(foundObj)
            }
            XCTAssertFalse(foundObj.isValid())
        } catch let error as RealmError {
            XCTFail(String(describing: error))
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
