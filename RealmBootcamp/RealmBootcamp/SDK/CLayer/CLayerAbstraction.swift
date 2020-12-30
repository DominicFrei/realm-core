//
//  CLayerAbstraction.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

struct CLayerAbstraction {
    
    static func realm(for cConfiguration: OpaquePointer) -> OpaquePointer {
        return realm_open(cConfiguration)
    }
    
    static func createConfiguration() -> OpaquePointer {
        return realm_config_new()
    }
    
    static func setPath(_ path: String, to configuration: OpaquePointer) throws {
        let realmPath = path.realmString()
        guard realm_config_set_path(configuration, realmPath) else {
            throw RealmError.InvalidPath
        }
    }
    
    // TODO: Works without?
//    static func applySchema(_ schema: OpaquePointer, to configuration: OpaquePointer) {
//        var success: Bool
//        success = realm_config_set_schema(configuration, schema)
//        assert(success)
//        success = realm_config_set_schema_mode(configuration, RLM_SCHEMA_MODE_AUTOMATIC)
//        assert(success)
//        success = realm_config_set_schema_version(configuration, 1)
//        assert(success)
//    }
    
    static func createSchema() -> OpaquePointer {
        return realm_schema_new(nil, 0, nil)
    }
    
    static func createSchema(classInfos: [ClassInfo], propertyInfos: [[PropertyInfo]]) throws -> OpaquePointer {
        let mappedClassInfo = classInfos.map { $0.toCClassInfo() }
        let mappedPropertyInfos: [[realm_property_info_t]] = propertyInfos.map {
            $0.map {
                $0.toCPropertyInfo()
            }
        }
        let unsafePointer = mappedPropertyInfos[0].withUnsafeBufferPointer({$0.baseAddress})
        let classPropertiesPointer = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: mappedClassInfo[0].num_properties)
        for index in 0..<mappedClassInfo.count {
            classPropertiesPointer.advanced(by: index).pointee = unsafePointer
        }
        guard let schema = realm_schema_new(mappedClassInfo, classInfos.count, classPropertiesPointer) else {
            throw RealmError.InvalidSchema
        }
        return schema
    }
    
    static func setSchema(_ schema: OpaquePointer, for realm: OpaquePointer) throws {
        let success = realm_set_schema(realm, schema)
        guard success else {
            throw RealmError.SchemaChange
        }
    }
    
    static func setSchema(_ schema: OpaquePointer, in configuration: OpaquePointer) throws {
        let success = realm_config_set_schema(configuration, schema)
        guard success else {
            throw RealmError.SchemaChange
        }
    }
    
    static func getSchema(for realm: OpaquePointer) -> OpaquePointer {
        return realm_get_schema(realm)
    }
    
    static func startTransaction(on realm: OpaquePointer) throws {
        let didSucceed = realm_begin_write(realm)
        guard didSucceed else {
            throw RealmError.StartTransaction
        }
    }
    
    static func endTransaction(on realm: OpaquePointer) throws {
        let didSucceed = realm_commit(realm)
        guard didSucceed else {
            throw RealmError.StartTransaction
        }
    }
    
    static func create<T: Persistable>(_ object: T, in realm: OpaquePointer) throws {
        guard let classInfo = find(object.typeName(), in: realm) else {
            throw RealmError.ClassNotFound
        }
        // TODO: Add option to create without primary key.
        var primaryKey = realm_value_t()
        guard let primaryKeyValue = object.properties().filter({ $0.label == object.primaryKey }).first?.value as? Int else {
            throw RealmError.PrimaryKeyViolation
        }
        primaryKey.integer = Int64(primaryKeyValue)
        primaryKey.type = RLM_TYPE_INT
        let createdObject = realm_object_create_with_primary_key(realm, classInfo.key.toCTableKey(), primaryKey)
        
        guard createdObject != nil else {
            throw RealmError.ObjectCreation
        }
    }
    
    static func find(_ className: String, in realm: OpaquePointer) -> ClassInfo? {
        let didFindClass = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let didSucceed = realm_find_class(realm, className.realmString(), didFindClass, classInfo)
        guard didSucceed && didFindClass.pointee else {
            return nil
        }
        return ClassInfo(classInfo.pointee)
    }
    
    static func findObject(with classInfo: ClassInfo, primaryKey: Int, in realm: OpaquePointer) throws -> OpaquePointer {
        
        // TODO: Primary key should be optional.
        var pkValue = realm_value_t()
        pkValue.integer = Int64(primaryKey)
        pkValue.type = RLM_TYPE_INT
        
        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        guard let retrievedObject = realm_object_find_with_primary_key(realm, classInfo.key.toCTableKey(), pkValue, found) else {
            throw RealmError.ObjectNotFound
        }
        guard found.pointee == true else {
            throw RealmError.ObjectNotFound
        }
        guard realm_object_is_valid(retrievedObject) else {
            throw RealmError.InvalidObject
        }
        return retrievedObject
    }
    
    static func retrievePropertyKeys(with classInfo: ClassInfo, in realm: OpaquePointer) throws -> [ColumnKey] {
        let tableKey = classInfo.key.toCTableKey()
        let propertyKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: classInfo.num_properties)
        let outNumber = UnsafeMutablePointer<size_t>.allocate(capacity: 1)
        guard realm_get_property_keys(realm, tableKey, propertyKeys, classInfo.num_properties, outNumber) else {
            throw RealmError.PropertiesNotFound
        }
        var columnKeys = [ColumnKey]()
        for i in 0..<classInfo.num_properties {
            let columnKey = ColumnKey(propertyKeys.advanced(by: i).pointee)
            columnKeys.append(columnKey)
        }
        return columnKeys
    }
    
    static func numberOfClasses(in realm: OpaquePointer) -> Int {
        return realm_get_num_classes(realm)
    }
    
    static func tableKeys(from realm: OpaquePointer) throws -> [TableKey] {
        let numberOfClasses = self.numberOfClasses(in: realm)
        let classKeys = UnsafeMutablePointer<realm_table_key_t>.allocate(capacity: numberOfClasses)
        let numberOfClassKeys = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let success = realm_get_class_keys(realm, classKeys, numberOfClasses, numberOfClassKeys)
        guard success && numberOfClasses == numberOfClassKeys.pointee else {
            throw RealmError.ClassNotFound
        }
        var tableKeys = [TableKey]()
        for i in 0..<numberOfClassKeys.pointee {
            let tableKey = TableKey(classKeys.advanced(by: i).pointee)
            tableKeys.append(tableKey)
        }
        return tableKeys
    }
    
    static func classInfo(for tableKey: TableKey, from realm: OpaquePointer) throws -> realm_class_info_t {
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        var rTableKey = realm_table_key_t()
        rTableKey.table_key = tableKey.key
        let success = realm_get_class(realm, rTableKey, classInfo)
        guard success else {
            throw RealmError.ClassNotFound
        }
        return classInfo.pointee
    }
    
    static func propertyInfo(for classInfo: realm_class_info_t, in realm: OpaquePointer) throws -> [PropertyInfo] {
        let numberOfProperties = classInfo.num_properties
        let propertyInfos = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: numberOfProperties)
        let returnedNumberOfProperties = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        let success = realm_get_class_properties(realm, classInfo.key, propertyInfos, numberOfProperties, returnedNumberOfProperties)
        guard success else {
            throw RealmError.PropertiesNotFound
        }
        var properties = [PropertyInfo]()
        for j in 0..<returnedNumberOfProperties.pointee {
            guard let propertyInfo = PropertyInfo(propertyInfos.advanced(by: j).pointee) else {
                throw RealmError.PropertiesNotFound
            }
            properties.append(propertyInfo)
        }
        return properties
    }
    
    static func getValues(for object: OpaquePointer, propertyKeys: [ColumnKey], classInfo: ClassInfo, in realm: OpaquePointer) throws -> [String: Encodable] {
        let outValues = UnsafeMutablePointer<realm_value_t>.allocate(capacity: classInfo.num_properties)
        let columnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: propertyKeys.count)
        for i in 0..<propertyKeys.count {
            columnKeys.advanced(by: i).pointee = propertyKeys[i].toCColumnKey()
        }
        guard realm_get_values(object, classInfo.num_properties, columnKeys, outValues) else {
            throw RealmError.FetchValuesFailed
        }
        
        var values = [String: Encodable]()
        for i in 0..<classInfo.num_properties {
            let outPropertyInfo = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
            realm_get_property(realm, classInfo.key.toCTableKey(), columnKeys.advanced(by: i).pointee, outPropertyInfo)
            switch outValues.advanced(by: i).pointee.type {
            case RLM_TYPE_INT:
                values[String(cString: outPropertyInfo.pointee.name.data)] = outValues.advanced(by: i).pointee.integer
            case RLM_TYPE_STRING:
                values[String(cString: outPropertyInfo.pointee.name.data)] = String(cString: outValues.advanced(by: i).pointee.string.data)
            default:
                assert(false)
            }
        }
        
        return values
    }
    
    static func updateValues(for object: OpaquePointer, propertyKeys: [ColumnKey], newValues: [Any]) throws {
        let columnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: propertyKeys.count)
        for i in 0..<propertyKeys.count {
            columnKeys.advanced(by: i).pointee = propertyKeys[i].toCColumnKey()
        }
        var realmValues = [realm_value_t]()
        for i in 0..<newValues.count {
            var value = realm_value_t()
            switch newValues[i] {
            case let newValue as Int:
                value.type = RLM_TYPE_INT
                value.integer = Int64(newValue)
            case let newValue as String:
                value.type = RLM_TYPE_STRING
                value.string = newValue.realmString()
            default:
                break
            }
            realmValues.append(value)
        }
        
        guard newValues.count == realmValues.count else {
            throw RealmError.UpdateFailed
        }
        
        let valuesAsPointer = UnsafeMutablePointer<realm_value_t>.allocate(capacity: realmValues.count)
        for i in 0..<realmValues.count {
            (valuesAsPointer + i).pointee = realmValues[i]
        }
        guard realm_set_values(object, realmValues.count, columnKeys, valuesAsPointer, false) else {
            throw RealmError.UpdateFailed
        }
    }
    
    static func delete(_ object: OpaquePointer) throws {
        guard realm_object_delete(object) else {
            throw RealmError.ObjectNotFound
        }
        
    }
    
}
