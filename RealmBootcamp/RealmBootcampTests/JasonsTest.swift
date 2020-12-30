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
    
    struct MyObject: Persistable {
        var int = 0
        var str = ""
        var primaryKey: String {
            return ""
        }
    }
    
    func test() {
        var obj = MyObject()
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
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertEqual(obj.str, "foo")
        XCTAssertTrue(obj.isValid())
        //        let foundObj = realm.object<MyObject>(primaryKey: 42)
        //        XCTAssertEqual(foundObj, obj)
        //        XCTAssertTrue(foundObj.isValid)
        //        XCTAssertEqual(foundObj.str, "foo")
        //        XCTAssertEqual(foundObj.int, 42)
        //        XCTAssertThrows(() { foundObj.int = 84})
        //        XCTAssertThrows(realm.delete(foundObj))
        //        realm.write {
        //            realm.delete(foundObj)
        //        }
        //        XCAssertFalse(foundObj.isValid)
    }
    
}
