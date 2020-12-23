//
//  C-API-Tests.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 21/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

class cApiTests: XCTestCase {
    
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
    
    func testClasses() {
        var foo = Foo()
        foo[keyPath: \.x] = 42
        var bar = Bar()
        bar.x = 42
        let baz = Baz()
        bar.x = 42
        var faz = Faz()
        faz.x = 42
        
        testCApi(foo)
        testCApi(bar)
        testCApi(baz)
        testCApi(faz)
    }
    
    func testCApi<T: Persistable>(_ testClass: T) {
        
        let realm = Realm(classes: [testClass.self])!
        
        // Create:
        realm.add(testClass)
        
        // Read:
        let (retrievedObject, outColumnKeys) = realm.find(testClass: testClass)
        
        // Update:
        var newFirstValue = realm_value_t()
        newFirstValue.integer = 23
        newFirstValue.type = RLM_TYPE_INT
        var newSecondValue = realm_value_t()
        newSecondValue.integer = 24
        newSecondValue.type = RLM_TYPE_INT
//        var newThirdValue = realm_value_t()
//        newThirdValue.integer = 25
//        newThirdValue.type = RLM_TYPE_INT
        let values = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 2)
        values.pointee = newFirstValue
        (values + 1).pointee = newSecondValue
//        (values + 2).pointee = newThirdValue
        success = realm.write {
            success = realm_set_values(retrievedObject, 2, outColumnKeys, values, false)
            XCTAssert(success)
        }
        XCTAssert(success)
        
        // Check the new value.
        let outValuesAfterUpdate = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 3)
        success = realm_get_values(retrievedObject, 2, outColumnKeys, outValuesAfterUpdate)
        XCTAssert(success)
        
        let firstPropertyAfterUpdate = outValuesAfterUpdate.pointee
        XCTAssertEqual(firstPropertyAfterUpdate.type, RLM_TYPE_INT)
        XCTAssertEqual(firstPropertyAfterUpdate.integer, 23)
        
        let secondPropertyAfterUpdate = outValuesAfterUpdate.advanced(by: 1).pointee
        XCTAssertEqual(secondPropertyAfterUpdate.type, RLM_TYPE_INT)
        XCTAssertEqual(secondPropertyAfterUpdate.integer, 24)
        
//        thirdProperty = outValues.advanced(by: 2).pointee
//        XCTAssertEqual(thirdProperty.type, RLM_TYPE_INT)
//        XCTAssertEqual(thirdProperty.integer, 25)
        
        
        // ==================
        // ===== DELETE =====
        // ==================
        
        success = realm.write {
            success = realm_object_delete(retrievedObject)
            XCTAssert(success)
        }
        XCTAssert(success)
        
        let classInfo = realm.classInfo(for: testClass)
        var amount = size_t()
        success = realm_get_num_objects(realm.cRealm, classInfo.key, &amount);
        XCTAssert(success)
        XCTAssertEqual(amount, 0)
        
        
    }
    
}
