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
        XCTAssertEqual(amount, 0)
        
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
        realm_get_property_keys(realm, tableKey, &outColumnKeys, 3, &outNumber)
        XCTAssertEqual(outNumber, 3)
        
        var outValues = realm_value_t()
        let success = realm_get_values(retrievedObject, 3, outColumnKeys, &outValues)
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
        
        
        
        // realm_get_class_properties
        // realm_get_property_keys
        // realm_get_property
        
        // realm_find_property
        // realm_find_property_by_public_name
        // realm_find_primary_key_property
        
        // realm_get_value
        // realm_get_values
        // realm_set_value
        // realm_set_values
        
        
        //        var outProperties = realm_property_info_t()
        //        var numberOfClassProperties = size_t()
        //        realm_get_class_properties(realm, tableKey, &outProperties, 3, &numberOfClassProperties)
        
        
        
        //        var outPropertyInfo = realm_property_info_t()
        //        realm_get_property(realm, tableKey, outColumnKeys, &outPropertyInfo)
        //        XCTAssertEqual(String(cString: outPropertyInfo.name.data), "x")
        //        XCTAssertEqual(outPropertyInfo.type, RLM_PROPERTY_TYPE_INT)
        //        XCTAssertEqual(outPropertyInfo.key.col_key, 0)
        //        XCTAssertEqual((&outPropertyInfo.col_key)+1, 0)
        
        //        var pointerrr = UnsafeMutablePointer<Int64>.allocate(capacity: 4)
        //        pointerrr = outPropertyInfo.key.col_key
        //        print(pointerrr.pointee)
        
        ///////////////////
        
        //        var p: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
        //        p.initialize(to: outColumnKeys.col_key)
        //        p.pointee
        //        UnsafePointer<Int64>(outColumnKeys.col_key)
        //        UnsafeBufferPointer(start: outColumnKeys.col_key, count: 3)
        
        //        let pointerrr = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        //        pointerrr.initialize(to: 0)
        //        (pointerrr + 1).initialize(to: 1)
        
        /////////////////////
        
        
        
        
        
        
        
        
        
        
        // ==================
        // ===== UDPATE =====
        // ==================
        
        // Update the property 'x' in 'foo' to be '23'.
        var newValue = realm_value_t()
        newValue.integer = 23
        newValue.type = RLM_TYPE_INT
        realm_begin_write(realm)
        realm_set_values(retrievedObject, 1, &outColumnKeys, &newValue, false)
        realm_commit(realm)
        
        // Check the new value.
        realm_get_values(retrievedObject, 3, outColumnKeys, &outValues)
        XCTAssertEqual(outValues.integer, 23)
        
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
