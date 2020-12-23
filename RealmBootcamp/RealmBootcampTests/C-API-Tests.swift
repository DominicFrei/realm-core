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
        let foo = Foo(x: 0, y: 0, z: 0)
        let bar = Bar(x: 0, y: 0, z: 0)
        let baz = Baz(x: 0, y: 0, z: "0")
        let faz = Faz(x: 0, y: 0, z: 0, a: "a", b: "b")
        
        testCApi(foo)
        testCApi(bar)
        testCApi(baz)
        testCApi(faz)
    }
    
    func testCApi<T: Persistable>(_ testClass: T) {
        
        var success = false
        
        let realm = Realm(classes: [testClass])!
        
        realm.add(testClass)
        
        // ================
        // ===== READ =====
        // ================
        
        // Find object of class 'foo' with primary key 'x' = 42
        let className = String(describing: type(of: testClass.self))
        let name = className.realmString()
        var outFound = false
        var outClassInfo = realm_class_info_t()
        success = realm_find_class(realm.cRealm, name, &outFound, &outClassInfo)
        XCTAssert(success)
        XCTAssertEqual(String(cString: outClassInfo.name.data), className)
        XCTAssertEqual(String(cString: outClassInfo.primary_key.data), "x")
        XCTAssertEqual(outClassInfo.num_properties, testClass.properties().count)
        
        var pkValue = realm_value_t()
        pkValue.integer = 42
        pkValue.type = RLM_TYPE_INT
        var found = false
        let retrievedObject = realm_object_find_with_primary_key(realm.cRealm, outClassInfo.key, pkValue, &found)
        XCTAssert(realm_object_is_valid(retrievedObject))
        
        // Read all values of this object.
        let tableKey = outClassInfo.key
        let outColumnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: 3)
        var outNumber = size_t()
        success = realm_get_property_keys(realm.cRealm, tableKey, outColumnKeys, 3, &outNumber)
        XCTAssert(success)
        XCTAssertEqual(outNumber, 3)
        
        let outValues = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 3)
        success = realm_get_values(retrievedObject, 3, outColumnKeys, outValues)
        XCTAssert(success)
        
        var firstProperty = outValues.pointee
        XCTAssertEqual(firstProperty.type, RLM_TYPE_INT)
        XCTAssertEqual(firstProperty.integer, 42)
        
        var secondProperty = outValues.advanced(by: 1).pointee
        XCTAssertEqual(secondProperty.type, RLM_TYPE_INT)
        XCTAssertEqual(secondProperty.integer, 0)
        
        var thirdProperty = outValues.advanced(by: 2).pointee
        XCTAssertEqual(thirdProperty.type, RLM_TYPE_INT)
        XCTAssertEqual(thirdProperty.integer, 0)
        
        
        // ==================
        // ===== UDPATE =====
        // ==================
        
        // Update the property 'x' in 'foo' to be '23'.
        var newFirstValue = realm_value_t()
        newFirstValue.integer = 23
        newFirstValue.type = RLM_TYPE_INT
        var newSecondValue = realm_value_t()
        newSecondValue.integer = 24
        newSecondValue.type = RLM_TYPE_INT
        var newThirdValue = realm_value_t()
        newThirdValue.integer = 25
        newThirdValue.type = RLM_TYPE_INT
        let values = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 3)
        values.pointee = newFirstValue
        (values + 1).pointee = newSecondValue
        (values + 2).pointee = newThirdValue
        success = realm.write {
            success = realm_set_values(retrievedObject, 3, outColumnKeys, values, false)
            XCTAssert(success)
        }
        XCTAssert(success)
        
        // Check the new value.
        success = realm_get_values(retrievedObject, 3, outColumnKeys, outValues)
        XCTAssert(success)
        
        firstProperty = outValues.pointee
        XCTAssertEqual(firstProperty.type, RLM_TYPE_INT)
        XCTAssertEqual(firstProperty.integer, 23)
        
        secondProperty = outValues.advanced(by: 1).pointee
        XCTAssertEqual(secondProperty.type, RLM_TYPE_INT)
        XCTAssertEqual(secondProperty.integer, 24)
        
        thirdProperty = outValues.advanced(by: 2).pointee
        XCTAssertEqual(thirdProperty.type, RLM_TYPE_INT)
        XCTAssertEqual(thirdProperty.integer, 25)
        
        
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
