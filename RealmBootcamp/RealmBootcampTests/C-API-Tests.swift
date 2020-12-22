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
    
    func testCApi_Foo() {
        
        realm_clear_last_error()
        
        guard let configuration = Configuration() else {
            XCTFail("Configuration must not be nil.")
            return
        }
        
        // Create classes.
        let testClass = Foo(x: 0, y: 0, z: 0)
        let classInfos: [realm_class_info] = [testClass.classInfo()]
        let classProperties: [[realm_property_info_t]] = [testClass.classProperties()]
        XCTAssertEqual(classProperties[0].count, testClass.classInfo().num_properties)
        
        guard var schema = Schema(classInfos: classInfos, classProperties: classProperties) else {
            XCTFail("Schema must not be nil.")
            return
        }
        
        
        // Open a realm.
        
        configuration.apply(schema: schema, mode: RLM_SCHEMA_MODE_AUTOMATIC, version: 1)
        let realm = Realm(configuration: configuration)
        schema.cSchema = realm_get_schema(realm.cRealm)
        
        // Check the initial state of the realm (empty).
        var amount = size_t()
        var found = false
        var newClassInfo = realm_class_info_t()
        var success = realm_find_class(realm.cRealm, testClass.classInfo().name, &found, &newClassInfo)
        XCTAssert(success)
        success = realm_get_num_objects(realm.cRealm, newClassInfo.key, &amount)
        XCTAssert(success)
        XCTAssertEqual(amount, 0)
        
        
        // ==================
        // ===== CREATE =====
        // ==================
        
        var primaryKeyValue = realm_value_t()
        primaryKeyValue.integer = 42
        primaryKeyValue.type = RLM_TYPE_INT
        success = realm_begin_write(realm.cRealm)
        XCTAssert(success)
        let object = realm_object_create_with_primary_key(realm.cRealm, newClassInfo.key, primaryKeyValue)
        success = realm_commit(realm.cRealm)
        XCTAssert(success)
        XCTAssert(realm_object_is_valid(object))
        
        success = realm_get_num_objects(realm.cRealm, newClassInfo.key, &amount)
        XCTAssert(success)
        XCTAssertEqual(amount, 1)
        
        
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
        XCTAssertEqual(outClassInfo.num_properties, 3)
        
        var pkValue = realm_value_t()
        pkValue.integer = 42
        pkValue.type = RLM_TYPE_INT
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
        success = realm_begin_write(realm.cRealm)
        XCTAssert(success)
        success = realm_set_values(retrievedObject, 3, outColumnKeys, values, false)
        XCTAssert(success)
        success = realm_commit(realm.cRealm)
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
        
        success = realm_begin_write(realm.cRealm)
        XCTAssert(success)
        success = realm_object_delete(retrievedObject)
        XCTAssert(success)
        success = realm_commit(realm.cRealm)
        XCTAssert(success)
        
        success = realm_get_num_objects(realm.cRealm, newClassInfo.key, &amount);
        XCTAssert(success)
        XCTAssertEqual(amount, 0)
        
        
        // =================
        // ===== ERROR =====
        // =================
        
        var error = realm_error_t()
        let errorFound = realm_get_last_error(&error)
        XCTAssertFalse(errorFound)
        if let data = error.message.data {
            print("ERROR: \(String(cString: data))")
        }
    }
    
    func testCApi_Baz() {
        
        realm_clear_last_error()
        
        guard let configuration = Configuration() else {
            XCTFail("Configuration must not be nil.")
            return
        }
        
        // Create classes.
        let testClass = Baz(x: 0, y: 0, z: "0")
        let classInfos: [realm_class_info] = [testClass.classInfo()]
        let classProperties: [[realm_property_info_t]] = [testClass.classProperties()]
        XCTAssertEqual(classProperties[0].count, testClass.classInfo().num_properties)
        
        guard var schema = Schema(classInfos: classInfos, classProperties: classProperties) else {
            XCTFail("Schema must not be nil.")
            return
        }
        
        
        // Open a realm.
        var success = realm_config_set_schema(configuration.cConfig, schema.cSchema)
        XCTAssert(success)
        success = realm_config_set_schema_mode(configuration.cConfig, RLM_SCHEMA_MODE_AUTOMATIC)
        XCTAssert(success)
        success = realm_config_set_schema_version(configuration.cConfig, 1)
        XCTAssert(success)
        let realm = realm_open(configuration.cConfig)
        schema.cSchema = realm_get_schema(realm)
        
        // Check the initial state of the realm (empty).
        var amount = size_t()
        var found = false
        var newClassInfo = realm_class_info_t()
        success = realm_find_class(realm, testClass.classInfo().name, &found, &newClassInfo)
        XCTAssert(success)
        success = realm_get_num_objects(realm, newClassInfo.key, &amount)
        XCTAssert(success)
        XCTAssertEqual(amount, 0)
        
        
        // ==================
        // ===== CREATE =====
        // ==================
        
        var primaryKeyValue = realm_value_t()
        primaryKeyValue.integer = 42
        primaryKeyValue.type = RLM_TYPE_INT
        success = realm_begin_write(realm)
        XCTAssert(success)
        let object = realm_object_create_with_primary_key(realm, newClassInfo.key, primaryKeyValue)
        success = realm_commit(realm)
        XCTAssert(success)
        XCTAssert(realm_object_is_valid(object))
        
        success = realm_get_num_objects(realm, newClassInfo.key, &amount)
        XCTAssert(success)
        XCTAssertEqual(amount, 1)
        
        
        // ================
        // ===== READ =====
        // ================
        
        // Find object of class 'foo' with primary key 'x' = 42
        let className = String(describing: type(of: testClass.self))
        let name = className.realmString()
        var outFound = false
        var outClassInfo = realm_class_info_t()
        success = realm_find_class(realm, name, &outFound, &outClassInfo)
        XCTAssert(success)
        XCTAssertEqual(String(cString: outClassInfo.name.data), className)
        XCTAssertEqual(String(cString: outClassInfo.primary_key.data), "x")
        XCTAssertEqual(outClassInfo.num_properties, 3)
        
        var pkValue = realm_value_t()
        pkValue.integer = 42
        pkValue.type = RLM_TYPE_INT
        let retrievedObject = realm_object_find_with_primary_key(realm, outClassInfo.key, pkValue, &found)
        XCTAssert(realm_object_is_valid(retrievedObject))
        
        // Read all values of this object.
        let tableKey = outClassInfo.key
        let outColumnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: 3)
        var outNumber = size_t()
        success = realm_get_property_keys(realm, tableKey, outColumnKeys, 3, &outNumber)
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
        XCTAssertEqual(thirdProperty.type, RLM_TYPE_STRING)
        XCTAssertEqual(String(cString: thirdProperty.string.data), "")
        
        
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
        newThirdValue.string = "25".realmString()
        newThirdValue.type = RLM_TYPE_STRING
        let values = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 3)
        values.pointee = newFirstValue
        (values + 1).pointee = newSecondValue
        (values + 2).pointee = newThirdValue
        success = realm_begin_write(realm)
        XCTAssert(success)
        success = realm_set_values(retrievedObject, 3, outColumnKeys, values, false)
        XCTAssert(success)
        success = realm_commit(realm)
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
        XCTAssertEqual(thirdProperty.type, RLM_TYPE_STRING)
        XCTAssertEqual(String(cString: thirdProperty.string.data), "25")
        
        
        // ==================
        // ===== DELETE =====
        // ==================
        
        success = realm_begin_write(realm)
        XCTAssert(success)
        success = realm_object_delete(retrievedObject)
        XCTAssert(success)
        success = realm_commit(realm)
        XCTAssert(success)
        
        success = realm_get_num_objects(realm, newClassInfo.key, &amount);
        XCTAssert(success)
        XCTAssertEqual(amount, 0)
        
        
        // =================
        // ===== ERROR =====
        // =================
        
        var error = realm_error_t()
        let errorFound = realm_get_last_error(&error)
        XCTAssertFalse(errorFound)
        if let data = error.message.data {
            print("ERROR: \(String(cString: data))")
        }
    }
    
}
