//
//  JasonsTest.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 29/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

// swiftlint:disable force_try
class JasonsTest: RealmTestsBaseClass {
    
    class MyObject: Persistable {
        @PersistedGeneric<Int>(isPrimaryKey: true) var intValue
        @PersistedGeneric<String> var stringValue
    }
    
    func test() {
        let obj = MyObject()
        obj.intValue = 42
        obj.stringValue = ""
        var realm: Realm!
        do {
            realm = try Realm()
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
//        XCTAssertThrowsError(try realm.add(obj))
        
        try! realm.write {
            try! realm.add(obj)
            obj.stringValue = "foo"
        }
        XCTAssertEqual(obj.stringValue, "foo")
        XCTAssertTrue(obj.isValid())
        let foundObj = try! realm.find(MyObject.self, withPrimaryKey: 42)
        XCTAssertEqual(foundObj, obj)
        XCTAssertTrue(foundObj.isValid())
        XCTAssertEqual(foundObj.stringValue, "foo")
        XCTAssertEqual(foundObj.intValue, 42)
//            XCTAssertThrowsError(foundObj.intValue = 84)
//            XCTAssertThrowsError(try realm.delete(foundObj))
        try! realm.write {
            try! realm.delete(foundObj)
        }
        XCTAssertFalse(foundObj.isValid())
        
        do {
            
        } catch let error as RealmError {
            XCTFail(String(describing: error))
        } catch let error {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
