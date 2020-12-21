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
        realm_config_set_path(cConfig, realmString)
    }
}

class RealmBootcampTests: XCTestCase {
    
    func testExample() throws {
        
        // Create a config.
        let config = Config()
        
        let numberOfClasses = 1
        let numberOfProperties = 3
        let emptyString = "".realmString()

        // Create a class.
        let className = "foo".realmString()
        let primaryKey = "x".realmString()
        var classInfo = realm_class_info()
        classInfo.name = className
        classInfo.primary_key = primaryKey
        classInfo.num_properties = numberOfProperties
        
        // Create properties.
        let propertyName1 = primaryKey
        let propertyName2 = "y".realmString()
        let propertyName3 = "z".realmString()
        var property1 = realm_property_info_t()
        property1.name = propertyName1
        property1.public_name = emptyString
        property1.type = RLM_PROPERTY_TYPE_INT
        property1.flags = Int32(RLM_PROPERTY_PRIMARY_KEY.rawValue)
        var property2 = realm_property_info_t()
        property2.name = propertyName2
        property2.public_name = emptyString
        property2.type = RLM_PROPERTY_TYPE_INT
        property2.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
        var property3 = realm_property_info_t()
        property3.name = propertyName3
        property3.public_name = emptyString
        property3.type = RLM_PROPERTY_TYPE_INT
        property3.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
        let classProperties = [property1, property2, property3]
        
        XCTAssertEqual(classProperties.count, numberOfProperties)
        
        // Create a schema.
        let unsafePointer = classProperties.withUnsafeBufferPointer({$0.baseAddress})
        let unsafeMutablePointer = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: numberOfProperties)
        for index in 0..<numberOfClasses {
            unsafeMutablePointer.advanced(by: index).pointee = unsafePointer
        }
        var schema = realm_schema_new([classInfo], numberOfClasses, unsafeMutablePointer)

        // Open a realm.
        realm_config_set_schema(config.cConfig, schema)
        realm_config_set_schema_mode(config.cConfig, RLM_SCHEMA_MODE_AUTOMATIC)
        realm_config_set_schema_version(config.cConfig, 1)
        let realm = realm_open(config.cConfig)
        schema = realm_get_schema(realm)

        // Check the initial state of the realm (empty).
        var amount = size_t()
        var found = false
        realm_find_class(realm, classInfo.name, &found, &classInfo)
        realm_get_num_objects(realm, classInfo.key, &amount);
        print("Initial realm state: \(amount) object(s) found.")

        // ==================
        // ===== CREATE =====
        // ==================

        var primaryKeyValue = realm_value_t()
        primaryKeyValue.integer = 42
        primaryKeyValue.type = RLM_TYPE_INT
        realm_begin_write(realm)
        let object = realm_object_create_with_primary_key(realm, classInfo.key, primaryKeyValue);
        realm_commit(realm)
        XCTAssert(realm_object_is_valid(object))

        realm_get_num_objects(realm, classInfo.key, &amount);
        XCTAssertEqual(amount, 1)

        // ================
        // ===== READ =====
        // ================
        
        // Find object of class 'foo' with primary key 'x' = 42
        let name = "foo".realmString()
        var outFound = false
        var outClassInfo = realm_class_info_t()
        realm_find_class(realm, name, &outFound, &outClassInfo)

        var pkValue = realm_value_t()
        pkValue.integer = 42
        pkValue.type = RLM_TYPE_INT
        let retrievedObject = realm_object_find_with_primary_key(realm, outClassInfo.key, pkValue, &found)
        XCTAssert(realm_object_is_valid(retrievedObject))

        // Read the value of 'x'.
        let tableKey = outClassInfo.key
        var outColumnKeys = realm_col_key_t()
        var outNumber = size_t()
        realm_get_property_keys(realm, tableKey, &outColumnKeys, 42, &outNumber)
        XCTAssertEqual(outNumber, 3)
        print("col keys: \(outColumnKeys.col_key)")
//        var p: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
//        p.initialize()
//        UnsafePointer<Int64>(outColumnKeys.col_key)
//        UnsafeBufferPointer(start: outColumnKeys.col_key, count: 3)
        var value = realm_value_t()
        realm_get_value(retrievedObject, outColumnKeys, &value)
        print("Value of x: \(value.integer)")

        // ==================
        // ===== UDPATE =====
        // ==================
        
        // Update the property 'x' in 'foo' to be '23'.
        var newValue = realm_value_t()
        newValue.integer = 23
        newValue.type = RLM_TYPE_INT
        realm_begin_write(realm)
        realm_set_value(retrievedObject, outColumnKeys, newValue, false)
        realm_commit(realm)

        // Check the new value.
        realm_get_property_keys(realm, tableKey, &outColumnKeys, 42, &outNumber)
        XCTAssertEqual(outNumber, 3)

        realm_get_value(retrievedObject, outColumnKeys, &value)
        XCTAssertEqual(value.integer, 23)

        // ==================
        // ===== DELETE =====
        // ==================

        realm_begin_write(realm)
        realm_object_delete(retrievedObject)
        realm_commit(realm)

        realm_get_num_objects(realm, classInfo.key, &amount);
        XCTAssertEqual(amount, 0)

        // =================
        // ===== ERROR =====
        // =================

        var error = realm_error_t()
        realm_get_last_error(&error)
        if let data = error.message.data {
            print("ERROR: \(String(cString: data))")
        }
    }

}
