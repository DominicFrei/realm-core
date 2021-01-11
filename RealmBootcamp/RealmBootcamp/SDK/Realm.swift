//
//  Realm.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

class Realm {
    
    let cRealm: OpaquePointer
    var configuration: Configuration
    var schema: Schema
    
    init() throws {
        configuration = try Configuration()
        cRealm = realm_open(configuration.cConfiguration)
        schema = Schema()
    }
    
}

// MARK: - Create

extension Realm {
    
    func add<T: Persistable>(_ object: T) throws {
        try addTypeIfNecessary(object)
        try create(object)
    }
    
    func addTypeIfNecessary<T: Persistable>(_ type: T) throws {
        guard Persistable.classInfoo(in: self) == nil else {
            return
        }
        let existingClassesCount = schema.objectSchemas.count
        let classInfos = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: existingClassesCount + 1)
        let classProperties = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: existingClassesCount + 1)

        for i in 0..<existingClassesCount {
            let (classInfo, classProperty): (realm_class_info_t, UnsafeMutablePointer<realm_property_info_t>) = schema.objectSchemas[i].handle
            classInfos.advanced(by: i).pointee = classInfo
            classProperties.advanced(by: i).pointee = UnsafePointer(classProperty)
        }

        // Add the new class to the existing class and property info.
        classInfos.advanced(by: existingClassesCount).pointee = type.classInfo().toCClassInfo()
        let classPropertyArray: [PropertyInfo] = try type.classProperties()
        let mappedProperties: [realm_property_info_t] = classPropertyArray.map {$0.handle}
        let propertiesAsUnsafePointer: UnsafePointer<realm_property_info_t> = mappedProperties.withUnsafeBufferPointer({$0.baseAddress!})
        classProperties.advanced(by: existingClassesCount).pointee = propertiesAsUnsafePointer

        // Set the new schema in the current realm.
        schema = try Schema(classInfos: classInfos, count: existingClassesCount + 1, classProperties: classProperties, realm: self)
        try endTransaction()
        guard realm_set_schema(cRealm, schema.cSchema) else {
            throw RealmError.SchemaChange
        }
        guard realm_config_set_schema(configuration.cConfiguration, schema.cSchema) else {
            throw RealmError.SchemaChange
        }
        schema.cSchema = realm_get_schema(cRealm)
        try startTransaction()
    }
    
    func create<T: Persistable>(_ object: T) throws {
        var primaryKey = realm_value_t()
        primaryKey.type = RLM_TYPE_INT
        primaryKey.integer = Int64(object.primaryKeyValue!)
        guard let tableKey = object.tableKey(in: self) else {
            throw RealmError.ClassNotFound
        }
        let createdObject = realm_object_create_with_primary_key(cRealm, tableKey, primaryKey)
        assert(realm_object_is_valid(createdObject))
        
        guard createdObject != nil else {
            throw RealmError.ObjectCreation
        }
        guard let classInfo = T.classInfoo(in: self) else {
            throw RealmError.ClassNotFound
        }
        
        let propertyKeys = try retrievePropertyKeys(with: classInfo)
        let mirror = Mirror(reflecting: object)
        let properties = mirror.children.map { Property(label: $0.label!, value: $0.value) }
        for i in 0..<properties.count {
            // swiftlint:disable force_cast
            (properties[i].value as! Persisted).realm = cRealm
            (properties[i].value as! Persisted).tableKey = Int(classInfo.key.key)
            (properties[i].value as! Persisted).columnKey = Int(propertyKeys[i].col_key)
            (properties[i].value as! Persisted).isManaged = true
            (properties[i].value as! Persisted).persist()
        }
    }
    
}

// MARK: - Read

extension Realm {
    
    func find2<T: Persistable>(_ type: T.Type, withPrimaryKey primaryKey: Int) throws -> T {
        guard let classInfo = type.classInfoo(in: self) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try retrievePropertyKeys(with: classInfo)
        
        let liveObject = T()
        liveObject.realm = cRealm
        liveObject.tableKey = classInfo.key.toCTableKey()
        liveObject.primaryKeyValue = primaryKey
        
        let mirror = Mirror(reflecting: liveObject)
        let properties = mirror.children.map { Property(label: $0.label!, value: $0.value) }
        // swiftlint:disable force_cast
        for i in 0..<properties.count {
            (properties[i].value as! Persisted).realm = cRealm
            (properties[i].value as! Persisted).tableKey = Int(classInfo.key.key)
            (properties[i].value as! Persisted).columnKey = Int(propertyKeys[i].col_key)
            (properties[i].value as! Persisted).isManaged = true
        }
        
        return liveObject
    }
    
    func getValues(for object: OpaquePointer, propertyKeys: [realm_col_key_t], classInfo: ClassInfo) throws -> [String: Encodable] {
        let outValues = UnsafeMutablePointer<realm_value_t>.allocate(capacity: classInfo.num_properties)
        let columnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: propertyKeys.count)
        for i in 0..<propertyKeys.count {
            columnKeys.advanced(by: i).pointee = propertyKeys[i]
        }
        guard realm_get_values(object, classInfo.num_properties, columnKeys, outValues) else {
            throw RealmError.FetchValuesFailed
        }
        
        var values = [String: Encodable]()
        for i in 0..<classInfo.num_properties {
            let outPropertyInfo = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
            realm_get_property(cRealm, classInfo.key.toCTableKey(), columnKeys.advanced(by: i).pointee, outPropertyInfo)
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
    
}

// MARK: - Update

extension Realm {
    
    func updateValues<T: Persistable>(objectOfType type: T.Type, withPrimaryKey primaryKey: Int, newValues: [Any]) throws {
        guard let classInfo = T.classInfoo(in: self) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try retrievePropertyKeys(with: classInfo)
        let object = try findObject(with: classInfo.key.toCTableKey(), primaryKey: primaryKey)
        
        let columnKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: propertyKeys.count)
        for i in 0..<propertyKeys.count {
            columnKeys.advanced(by: i).pointee = propertyKeys[i]
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
    
}

// MARK: - Delete

extension Realm {
    
    func delete<T: Persistable>(_ object: T) throws {
        let primaryKeyValue = object.primaryKeyValue!
        guard let tableKey = object.tableKey(in: self) else {
            throw RealmError.ClassNotFound
        }
        let object = try findObject(with: tableKey, primaryKey: primaryKeyValue)
        guard realm_object_delete(object) else {
            throw RealmError.ObjectNotFound
        }
    }
    
}

// MARK: - Transactions

extension Realm {
    
    func write(_ transaction: () throws -> Void) throws {
        try startTransaction()
        try transaction()
        try endTransaction()
    }
    
    func startTransaction() throws {
        guard realm_begin_write(cRealm) else {
            throw RealmError.StartTransaction
        }
    }
    
    func endTransaction() throws {
        guard realm_commit(cRealm) else {
            throw RealmError.EndTransaction
        }
    }
    
}

// MARK: - Helper Functions

extension Realm {
    
    func findObject(with tableKey: realm_table_key_t, primaryKey: Int) throws -> OpaquePointer {
        var pkValue = realm_value_t()
        pkValue.type = RLM_TYPE_INT
        pkValue.integer = Int64(primaryKey)
        
        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        guard let retrievedObject = realm_object_find_with_primary_key(cRealm, tableKey, pkValue, found) else {
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
    
    func retrievePropertyKeys(with classInfo: ClassInfo) throws -> [realm_col_key_t] {
        let tableKey = classInfo.key.toCTableKey()
        let propertyKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: classInfo.num_properties)
        let outNumber = UnsafeMutablePointer<size_t>.allocate(capacity: 1)
        guard realm_get_property_keys(cRealm, tableKey, propertyKeys, classInfo.num_properties, outNumber) else {
            throw RealmError.PropertiesNotFound
        }
        var columnKeys = [realm_col_key_t]()
        for i in 0..<classInfo.num_properties {
            let columnKey = propertyKeys.advanced(by: i).pointee
            columnKeys.append(columnKey)
        }
        return columnKeys
    }
    
}
