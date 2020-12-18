//
//  main.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 17/12/2020.
//

import RealmC

// Create a config.
public struct Config {
    let cConfig: OpaquePointer
    public init() {
        self.cConfig = realm_config_new()
        let path = "test19.realm"
        let realmString = realm_string(data: strdup(path), size: path.count)
        realm_config_set_path(cConfig, realmString)
    }
}
let config = Config()

// Create a schema.
let className = realm_string(data: strdup("foo"), size: "foo".count)
let primaryKey = realm_string(data: strdup("x"), size: "x".count)
var classInfo = realm_class_info()
classInfo.name = className
classInfo.primary_key = primaryKey
classInfo.num_properties = 3
let propertyName1 = realm_string(data: strdup("x"), size: "x".count)
let propertyName2 = realm_string(data: strdup("y"), size: "y".count)
let propertyName3 = realm_string(data: strdup("z"), size: "z".count)
let emptyString = realm_string(data: strdup(""), size: "".count)
var property1 = realm_property_info_t()
property1.name = realm_string(data: strdup("x"), size: "x".count)
property1.public_name = emptyString
property1.type = RLM_PROPERTY_TYPE_INT
property1.flags = Int32(RLM_PROPERTY_PRIMARY_KEY.rawValue)
var property2 = realm_property_info_t()
property2.name = realm_string(data: strdup("y"), size: "y".count)
property2.public_name = emptyString
property2.type = RLM_PROPERTY_TYPE_INT
property2.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
var property3 = realm_property_info_t()
property3.name = realm_string(data: strdup("z"), size: "z".count)
property3.public_name = emptyString
property3.type = RLM_PROPERTY_TYPE_INT
property3.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
var classProperties = [property1, property2, property3]
var unsafeBufferPointer = classProperties.withUnsafeBufferPointer({$0.baseAddress})
var unsafeMutablePointer = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: 3)
for index in 0...3 {
    unsafeMutablePointer.advanced(by: index).pointee = unsafeBufferPointer
}
var schema = realm_schema_new([classInfo], 1, unsafeMutablePointer)

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

// ===== CREATE =====

realm_begin_write(realm)
var primaryKeyValue = realm_value_t()
primaryKeyValue.integer = 42
primaryKeyValue.type = RLM_TYPE_INT
var object = realm_object_create_with_primary_key(realm, classInfo.key, primaryKeyValue);
realm_commit(realm)
assert(realm_object_is_valid(object))

realm_get_num_objects(realm, classInfo.key, &amount);
print("\(amount) object(s) found.")

// ===== READ =====
// Find object of class 'foo' with primary key 'x' = 42

let name = realm_string(data: strdup("foo"), size: "foo".count)
var outFound = false
var outClassInfo = realm_class_info_t()
realm_find_class(realm, name, &outFound, &outClassInfo)

var pkValue = realm_value_t()
pkValue.integer = 42
pkValue.type = RLM_TYPE_INT
var retrievedObject = realm_object_find_with_primary_key(realm, outClassInfo.key, pkValue, &found)

// Read the value of 'x'.
var tableKey = outClassInfo.key
var outColumnKeys = realm_col_key_t()
var outNumber = size_t()
realm_get_property_keys(realm, tableKey, &outColumnKeys, 42, &outNumber)
assert(outNumber == 3)
print(outColumnKeys.col_key)
//var p: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
//p.initialize()
//UnsafePointer<Int64>(outColumnKeys.col_key)
//UnsafeBufferPointer(start: outColumnKeys.col_key, count: 3)

var value = realm_value_t()
realm_get_value(retrievedObject, outColumnKeys, &value)
print(value.integer)

// ===== UDPATE =====
// Update the property 'x' in 'foo' to be '23'.

var newValue = realm_value_t()
newValue.integer = 23
newValue.type = RLM_TYPE_INT
realm_begin_write(realm)
realm_set_value(retrievedObject, outColumnKeys, newValue, false)
realm_commit(realm)

// Check again
realm_get_property_keys(realm, tableKey, &outColumnKeys, 42, &outNumber)
assert(outNumber == 3)
print(outColumnKeys)

realm_get_value(retrievedObject, outColumnKeys, &value)
print(value.integer)

// ===== DELETE =====

realm_begin_write(realm)
realm_object_delete(retrievedObject)
realm_commit(realm)

realm_get_num_objects(realm, classInfo.key, &amount);
print("\(amount) object(s) found.")

// =====

var error = realm_error_t()
realm_get_last_error(&error)
if let data = error.message.data {
    print(String(cString: data))
}
