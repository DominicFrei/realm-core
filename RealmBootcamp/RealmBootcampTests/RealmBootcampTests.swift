//
//  RealmBootcampTests.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 21/12/2020.
//

import XCTest
@testable import RealmBootcamp
import RealmC

extension String {
    func realmString() -> realm_string {
        realm_string(data: strdup(self), size: self.count)
    }
}

struct Config {
    let cConfig: OpaquePointer
    public init() {
        self.cConfig = realm_config_new()
        let uuid = UUID().uuidString
        let path = "\(uuid).realm"
        let realmString = path.realmString()
        let success = realm_config_set_path(cConfig, realmString)
        XCTAssert(success)
    }
}

class RealmBootcampTests: XCTestCase {
    
    func testExample() throws {
        
        // Create a config.
        let config = Config()
        
        // Create classes.
        let className = "foo".realmString()
        let primaryKey = "x".realmString()
        var classInfo = realm_class_info()
        classInfo.name = className
        classInfo.primary_key = primaryKey
        let numberOfProperties = 3
        classInfo.num_properties = numberOfProperties
        let classes = [classInfo]
        
        // Create properties.
        let propertyName1 = primaryKey
        let propertyName2 = "y".realmString()
        let propertyName3 = "z".realmString()
        var property1 = realm_property_info_t()
        property1.name = propertyName1
        property1.public_name = "".realmString()
        property1.type = RLM_PROPERTY_TYPE_INT
        property1.flags = Int32(RLM_PROPERTY_PRIMARY_KEY.rawValue)
        var property2 = realm_property_info_t()
        property2.name = propertyName2
        property2.public_name = "".realmString()
        property2.type = RLM_PROPERTY_TYPE_INT
        property2.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
        var property3 = realm_property_info_t()
        property3.name = propertyName3
        property3.public_name = "".realmString()
        property3.type = RLM_PROPERTY_TYPE_INT
        property3.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
        let classProperties = [property1, property2, property3]
        
        XCTAssertEqual(classProperties.count, numberOfProperties)
        
        for var classInfo in classes {
            classInfo.num_properties = classProperties.count
        }
        
        // Create a schema.
        let unsafePointer = classProperties.withUnsafeBufferPointer({$0.baseAddress})
        let unsafeMutablePointer = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: numberOfProperties)
        for index in 0..<classes.count {
            unsafeMutablePointer.advanced(by: index).pointee = unsafePointer
        }
        var schema = realm_schema_new(classes, classes.count, unsafeMutablePointer)
        
        // Open a realm.
        var success = realm_config_set_schema(config.cConfig, schema)
        XCTAssert(success)
        success = realm_config_set_schema_mode(config.cConfig, RLM_SCHEMA_MODE_AUTOMATIC)
        XCTAssert(success)
        success = realm_config_set_schema_version(config.cConfig, 1)
        XCTAssert(success)
        let realm = realm_open(config.cConfig)
        schema = realm_get_schema(realm)
        
        // Check the initial state of the realm (empty).
        var amount = size_t()
        var found = false
        success = realm_find_class(realm, classInfo.name, &found, &classInfo)
        XCTAssert(success)
        success = realm_get_num_objects(realm, classInfo.key, &amount)
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
        let object = realm_object_create_with_primary_key(realm, classInfo.key, primaryKeyValue)
        success = realm_commit(realm)
        XCTAssert(success)
        XCTAssert(realm_object_is_valid(object))
        
        success = realm_get_num_objects(realm, classInfo.key, &amount)
        XCTAssert(success)
        XCTAssertEqual(amount, 1)
        
        
        // ================
        // ===== READ =====
        // ================
        
        // Find object of class 'foo' with primary key 'x' = 42
        let name = "foo".realmString()
        var outFound = false
        var outClassInfo = realm_class_info_t()
        success = realm_find_class(realm, name, &outFound, &outClassInfo)
        XCTAssert(success)
        XCTAssertEqual(String(cString: outClassInfo.name.data), "foo")
        XCTAssertEqual(String(cString: outClassInfo.primary_key.data), "x")
        XCTAssertEqual(outClassInfo.num_properties, 3)
        
        var pkValue = realm_value_t()
        pkValue.integer = 42
        pkValue.type = RLM_TYPE_INT
        let retrievedObject = realm_object_find_with_primary_key(realm, outClassInfo.key, pkValue, &found)
        XCTAssert(realm_object_is_valid(retrievedObject))
        
        // Read all values of this object.
        let tableKey = outClassInfo.key
        var outColumnKeys = [realm_col_key_t]()
        var outNumber = size_t()
        success = realm_get_property_keys(realm, tableKey, &outColumnKeys, 3, &outNumber)
        XCTAssert(success)
        XCTAssertEqual(outNumber, 3)
        
        var outValues = realm_value_t()
        success = realm_get_values(retrievedObject, 3, outColumnKeys, &outValues)
        XCTAssert(success)
        
        withUnsafeMutablePointer(to: &outValues) { (unsafeMutablePointer) -> Void in
            let firstProperty: realm_value_t = unsafeMutablePointer.pointee
            XCTAssertEqual(firstProperty.type, RLM_TYPE_INT)
            XCTAssertEqual(firstProperty.integer, 42)
            
            let secondProperty: realm_value_t = unsafeMutablePointer.advanced(by: 1).pointee
            XCTAssertEqual(secondProperty.type, RLM_TYPE_INT)
            XCTAssertEqual(secondProperty.integer, 0)
            
            let thirdProperty: realm_value_t = unsafeMutablePointer.advanced(by: 2).pointee
            XCTAssertEqual(thirdProperty.type, RLM_TYPE_INT)
            XCTAssertEqual(thirdProperty.integer, 0)
        }
        
        
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
        success = realm_begin_write(realm)
        XCTAssert(success)
        success = realm_set_values(retrievedObject, 3, &outColumnKeys, values, false)
        XCTAssert(success)
        success = realm_commit(realm)
        XCTAssert(success)
        
        // Check the new value.
        success = realm_get_values(retrievedObject, 3, outColumnKeys, &outValues)
        XCTAssert(success)
        
        withUnsafeMutablePointer(to: &outValues) { (unsafeMutablePointer) -> Void in
            let firstProperty: realm_value_t = unsafeMutablePointer.pointee
            XCTAssertEqual(firstProperty.type, RLM_TYPE_INT)
            XCTAssertEqual(firstProperty.integer, 23)
            
            let secondProperty: realm_value_t = unsafeMutablePointer.advanced(by: 1).pointee
            XCTAssertEqual(secondProperty.type, RLM_TYPE_INT)
            XCTAssertEqual(secondProperty.integer, 24)
            
            let thirdProperty: realm_value_t = unsafeMutablePointer.advanced(by: 2).pointee
            XCTAssertEqual(thirdProperty.type, RLM_TYPE_INT)
            XCTAssertEqual(thirdProperty.integer, 25)
        }
        
        
        // ==================
        // ===== DELETE =====
        // ==================
        
        success = realm_begin_write(realm)
        XCTAssert(success)
        success = realm_object_delete(retrievedObject)
        XCTAssert(success)
        success = realm_commit(realm)
        XCTAssert(success)
        
        success = realm_get_num_objects(realm, classInfo.key, &amount);
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
