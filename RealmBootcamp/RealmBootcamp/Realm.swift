//
//  Realm.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

struct Realm {
    
    let cRealm: OpaquePointer
    
    var configuration: Configuration
    var schema: Schema
    
    init?<T: Persistable>(classes: [T]) {
        
        guard let configuration = Configuration() else {
            return nil
        }
        guard let schema = Schema(classes: classes) else {
            return nil
        }
        
        configuration.apply(schema: schema, mode: RLM_SCHEMA_MODE_AUTOMATIC, version: 1)
        
        self.init(configuration: configuration)
        
        self.schema.cSchema = realm_get_schema(cRealm)
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
        cRealm = realm_open(configuration.cConfig)
        schema = Schema()
    }
    
    func write(_ transaction: () -> Void) -> Bool {
        let beginWriteSuccess = realm_begin_write(cRealm)
        transaction()
        let commitSuccess = realm_commit(cRealm)
        return beginWriteSuccess && commitSuccess
    }
    
    func classInfo<T: Persistable>(for type: T) -> realm_class_info_t {
        var amount = size_t()
        var found = false
        var classInfo = realm_class_info_t()
        var success = realm_find_class(cRealm, type.classInfo().name, &found, &classInfo)
        assert(success)
        success = realm_get_num_objects(cRealm, classInfo.key, &amount)
        assert(success)
        return classInfo
    }
    
    func add<T: Persistable>(_ object: T) {
        
        let info = classInfo(for: object)
        
        var primaryKeyValue = realm_value_t()
        primaryKeyValue.integer = 42
        primaryKeyValue.type = RLM_TYPE_INT
        var object: OpaquePointer?
        var success = write {
            object = realm_object_create_with_primary_key(cRealm, info.key, primaryKeyValue)
        }
        assert(success)
        assert(realm_object_is_valid(object))
        
        var amount = size_t()
        success = realm_get_num_objects(cRealm, info.key, &amount)
        assert(success)
        assert(amount == 1)
    }
    
    func find<T: Persistable>(testClass: T) -> (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>) {
        // Find object of class 'foo' with primary key 'x' = 42
        let className = String(describing: type(of: testClass.self))
        let name = className.realmString()
        var outFound = false
        var outClassInfo = realm_class_info_t()
        var success = realm_find_class(cRealm, name, &outFound, &outClassInfo)
        assert(success)
        assert(String(cString: outClassInfo.name.data) == className)
        assert(String(cString: outClassInfo.primary_key.data) == "x")
        assert(outClassInfo.num_properties == testClass.properties().count)

        var pkValue = realm_value_t()
        pkValue.integer = 42
        pkValue.type = RLM_TYPE_INT
        var found = false
        let retrievedObject = realm_object_find_with_primary_key(cRealm, outClassInfo.key, pkValue, &found)
        assert(realm_object_is_valid(retrievedObject))

        // Read all values of this object.
        let tableKey = outClassInfo.key
        let outColumnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: 3)
        var outNumber = size_t()
        success = realm_get_property_keys(cRealm, tableKey, outColumnKeys, 3, &outNumber)
        assert(success)
        assert(outNumber == 3)

        print(outColumnKeys.pointee)
        print(outColumnKeys.advanced(by: 1).pointee)
        print(outColumnKeys.advanced(by: 2).pointee)

        let outPropertyInfo1 = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
        realm_get_property(cRealm, outClassInfo.key, outColumnKeys.pointee, outPropertyInfo1)
        let outPropertyInfo2 = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
        realm_get_property(cRealm, outClassInfo.key, outColumnKeys.advanced(by: 1).pointee, outPropertyInfo2)

        let outValues = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 3)
        success = realm_get_values(retrievedObject, 3, outColumnKeys, outValues)
        assert(success)



        print(String(cString: outPropertyInfo1.pointee.name.data))
        print(outValues.pointee.integer)
        print(String(cString: outPropertyInfo2.pointee.name.data))
        print(outValues.advanced(by: 1).pointee.integer)

        let firstProperty = outValues.pointee
        assert(firstProperty.type == RLM_TYPE_INT)
        assert(firstProperty.integer == 42)

        let secondProperty = outValues.advanced(by: 1).pointee
        assert(secondProperty.type == RLM_TYPE_INT)
        assert(secondProperty.integer == 0)
        
//        var thirdProperty = outValues.advanced(by: 2).pointee
//        assert(thirdProperty.type, RLM_TYPE_INT)
//        assert(thirdProperty.integer, 0)
        
        return (retrievedObject, outColumnKeys)
    }
    
}
