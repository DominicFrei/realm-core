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

// MARK: - Create (OLD)

extension Realm {
    
    func add<T: Persistable>(_ object: T) throws {
        try addTypeIfNecessary(object)
        try create(object)
    }
    
    func addTypeIfNecessary<T: Persistable>(_ type: T) throws {
        guard T.classInfoo(in: self) == nil else {
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
        // TODO: Add option to create without primary key.
        var primaryKey = realm_value_t()
        let primaryKeyValue = try object.primaryKeyValue()
        primaryKey.integer = Int64(primaryKeyValue)
        primaryKey.type = RLM_TYPE_INT
        guard let tableKey = object.tableKey(in: self) else {
            throw RealmError.ClassNotFound
        }
        let createdObject = realm_object_create_with_primary_key(cRealm, tableKey, primaryKey)
        
        guard createdObject != nil else {
            throw RealmError.ObjectCreation
        }
    }
    
}

// MARK: - Create (NEW)

extension Realm {
    
    func add2<T: Persistable2>(_ object: T) throws {
        try addTypeIfNecessary2(object)
        try create2(object)
    }
    
    func addTypeIfNecessary2<T: Persistable2>(_ type: T) throws {
        guard Persistable2.classInfoo(in: self) == nil else {
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
    
    func create2<T: Persistable2>(_ object: T) throws {
        // TODO: Add option to create without primary key.
        var primaryKey = realm_value_t()
        let primaryKeyValue = try object.primaryKeyValue()
        primaryKey.integer = Int64(primaryKeyValue)
        primaryKey.type = RLM_TYPE_INT
        guard let tableKey = object.tableKey(in: self) else {
            throw RealmError.ClassNotFound
        }
        let createdObject = realm_object_create_with_primary_key(cRealm, tableKey, primaryKey)
        
        guard createdObject != nil else {
            throw RealmError.ObjectCreation
        }
    }
    
}

// MARK: - Read (OLD)

extension Realm {
    
    func find<T: Persistable>(_ type: T.Type, withPrimaryKey primaryKey: Int) throws -> T {
        guard let classInfo = T.classInfoo(in: self) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try retrievePropertyKeys(with: classInfo)
        let object = try findObject(with: classInfo.key.toCTableKey(), primaryKey: primaryKey)
        let values: [String: Encodable] = try getValues(for: object, propertyKeys: propertyKeys, classInfo: classInfo)
        
        let wrappedDict = values.mapValues(EncodableWrapper.init(wrapped:))
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        var model: T!
        
        let jsonData = try jsonEncoder.encode(wrappedDict)
        let json = String(decoding: jsonData, as: UTF8.self)
        let data = json.data(using: .utf8)
        model = decodeData(data!)
        
        return model!
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

// MARK: - Read (NEW)

extension Realm {
    
    func find2<T: Persistable2>(_ type: T.Type, withPrimaryKey primaryKey: Int) throws -> T {
        guard let classInfo = type.classInfoo(in: self) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try retrievePropertyKeys(with: classInfo)
        let object = try findObject(with: classInfo.key.toCTableKey(), primaryKey: primaryKey)
        let values: [String: Encodable] = try getValues2(for: object, propertyKeys: propertyKeys, classInfo: classInfo)
        
        
        let liveObject = Persistable2()
     
        // swiftlint:disable:next force_cast
        return liveObject as! T
    }
    
    func getValues2(for object: OpaquePointer, propertyKeys: [realm_col_key_t], classInfo: ClassInfo) throws -> [String: Encodable] {
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
        let primaryKeyValue = try object.primaryKeyValue()
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
        
        // TODO: Primary key should be optional.
        var pkValue = realm_value_t()
        pkValue.integer = Int64(primaryKey)
        pkValue.type = RLM_TYPE_INT
        
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

// MARK: - Decoding

extension Realm {
    
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }
    
    func decodeData<T: Persistable>(_ data: Data) -> T? {
        var model: T?
        do {
            model = try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            print(error.localizedDescription)
            assert(false)
        }
        return model
    }
    
}
