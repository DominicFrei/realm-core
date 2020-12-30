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
        cRealm = realm_open(configuration.cConfig)
        schema = Schema()
    }
    
    func write(_ transaction: () throws -> Void) throws {
        guard realm_begin_write(cRealm) else {
            throw RealmError.BeginWriteFailed
        }
        try transaction()
        guard realm_commit(cRealm) else {
            throw RealmError.CommitFailed
        }
    }
    
    func classInfo<T: Persistable>(for type: T) throws -> realm_class_info_t {
        var found = false
        var classInfo = realm_class_info_t()
        guard realm_find_class(cRealm, type.classInfo().name, &found, &classInfo) else {
            throw RealmError.ClassNotFound
        }
        return classInfo
    }
    
    func add<T: Persistable>(_ object: T) throws {
        
        // Check if the class already exists in the schema.
        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        var success = realm_find_class(cRealm, object.typeName().realmString(), found, nil)
        assert(success)
        
        if !found.pointee {
            
            // Get the class infos and property infos of the current schema
            let numberOfClasses = realm_get_num_classes(cRealm)
            let tableKeys = UnsafeMutablePointer<realm_table_key_t>.allocate(capacity: numberOfClasses)
            let numberOfClassKeys = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            success = realm_get_class_keys(cRealm, tableKeys, numberOfClasses, numberOfClassKeys)
            guard success else {
                throw RealmError.SchemaChange
            }
            
            var classInfos = [realm_class_info]()
            var classProperties = [[realm_property_info_t]]()
            for i in 0..<numberOfClassKeys.pointee {
                let tableKey = tableKeys.advanced(by: i).pointee
                let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
                success = realm_get_class(cRealm, tableKey, classInfo)
                guard success else {
                    throw RealmError.SchemaChange
                }
                classInfos.append(classInfo.pointee)
                let numberOfProperties = classInfo.pointee.num_properties
                let propertyInfos = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: numberOfProperties)
                let returnedNumberOfProperties = UnsafeMutablePointer<Int>.allocate(capacity: 1)
                success = realm_get_class_properties(cRealm, tableKey, propertyInfos, numberOfProperties, returnedNumberOfProperties)
                guard success else {
                    throw RealmError.SchemaChange
                }
                var properties = [realm_property_info_t]()
                for j in 0..<returnedNumberOfProperties.pointee {
                    properties.append(propertyInfos.advanced(by: j).pointee)
                }
                classProperties.append(properties)
            }
            
            // Add the new class to the existing class and property info.
            classInfos.append(object.classInfo())
            classProperties.append(object.classProperties())
            
            // Set the new schema in the current realm.
            guard let newSchema = Schema(classInfos: classInfos, classProperties: classProperties) else {
                throw RealmError.SchemaChange
            }
            schema = newSchema
            realm_commit(cRealm)
            success = realm_set_schema(cRealm, schema.cSchema)
            guard success else {
                throw RealmError.SchemaChange
            }
            
            success = realm_config_set_schema(configuration.cConfig, schema.cSchema)
            guard success else {
                throw RealmError.SchemaChange
            }
            
            self.schema.cSchema = realm_get_schema(cRealm)
            realm_begin_write(cRealm)
        }
        
        let info = try classInfo(for: object)
        var primaryKey = realm_value_t()
        guard let primaryKeyValue = object.properties().filter({ $0.label == object.primaryKey }).first?.value as? Int else {
            throw RealmError.PrimaryKeyViolation
        }
        primaryKey.integer = Int64(primaryKeyValue)
        primaryKey.type = RLM_TYPE_INT
        let createdObject = realm_object_create_with_primary_key(cRealm, info.key, primaryKey)
        guard createdObject != nil else {
            throw RealmError.ClassNotFound
        }
        guard realm_object_is_valid(createdObject) else {
            throw RealmError.InvalidObject
        }
    }
    
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }
    
    // Large tuple will be removed soon anyway.
    // swiftlint:disable large_tuple
    func find<T: Persistable>(testClass: T, withPrimaryKey primaryKey: Int) throws -> (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>, T) {
        let classInfo = retrieveClassInfo(for: testClass)
        let propertyKeys = retrievePropertyKeys(with: classInfo)
        let object = try findObject(with: classInfo, primaryKey: primaryKey)
        let values: [String: Encodable] = try getValues(for: object, propertyKeys: propertyKeys, classInfo: classInfo)
        
        let wrappedDict = values.mapValues(EncodableWrapper.init(wrapped:))
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        var model: T!
        
        let jsonData = try jsonEncoder.encode(wrappedDict)
        let json = String(decoding: jsonData, as: UTF8.self)
        let data = json.data(using: .utf8)
        model = decodeData(data!)
        
        return (object, propertyKeys, model!)
    }
    
    func decodeData<T: Persistable>(_ data: Data) -> T? {
        var model: T?
        do {
            model = try JSONDecoder().decode(T.self, from: data)
        } catch {
            assert(false)
        }
        return model
    }
    
    func retrieveClassInfo<T: Persistable>(for testClass: T) -> UnsafeMutablePointer<realm_class_info_t> {
        let className = String(describing: type(of: testClass.self))
        let name = className.realmString()
        let outFound = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let success = realm_find_class(cRealm, name, outFound, classInfo)
        assert(outFound.pointee)
        assert(success)
        assert(String(cString: classInfo.pointee.name.data) == className)
        assert(classInfo.pointee.num_properties == testClass.properties().count)
        return classInfo
    }
    
    func findObject(with classInfo: UnsafeMutablePointer<realm_class_info_t>, primaryKey: Int) throws -> OpaquePointer {
        var pkValue = realm_value_t()
        pkValue.integer = Int64(primaryKey)
        pkValue.type = RLM_TYPE_INT
        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        guard let retrievedObject = realm_object_find_with_primary_key(cRealm, classInfo.pointee.key, pkValue, found) else {
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
    
    func retrievePropertyKeys(with classInfo: UnsafeMutablePointer<realm_class_info_t>) -> UnsafeMutablePointer<realm_col_key_t> {
        let tableKey = classInfo.pointee.key
        let propertyKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: classInfo.pointee.num_properties)
        let outNumber = UnsafeMutablePointer<size_t>.allocate(capacity: 1)
        let success = realm_get_property_keys(cRealm, tableKey, propertyKeys, classInfo.pointee.num_properties, outNumber)
        assert(success)
        assert(outNumber.pointee == classInfo.pointee.num_properties)
        return propertyKeys
    }
    
    func getValues(for object: OpaquePointer, propertyKeys: UnsafeMutablePointer<realm_col_key_t>, classInfo: UnsafeMutablePointer<realm_class_info_t>) throws -> [String: Encodable] {
        let outValues = UnsafeMutablePointer<realm_value_t>.allocate(capacity: classInfo.pointee.num_properties)
        guard realm_get_values(object, classInfo.pointee.num_properties, propertyKeys, outValues) else {
            throw RealmError.FetchValuesFailed
        }
        
        var values = [String: Encodable]()
        for i in 0..<classInfo.pointee.num_properties {
            let outPropertyInfo = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
            realm_get_property(cRealm, classInfo.pointee.key, propertyKeys.advanced(by: i).pointee, outPropertyInfo)
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
    
    func updateValues(for object: OpaquePointer, propertyKeys: UnsafeMutablePointer<realm_col_key_t>, newValues: [Any]) throws -> Bool {
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
        
        assert(newValues.count == realmValues.count)
        
        let valuesAsPointer = UnsafeMutablePointer<realm_value_t>.allocate(capacity: realmValues.count)
        for i in 0..<realmValues.count {
            (valuesAsPointer + i).pointee = realmValues[i]
        }
        
        return realm_set_values(object, realmValues.count, propertyKeys, valuesAsPointer, false)
    }
    
    func delete<T: Persistable>(_ object: OpaquePointer, of testClass: T) -> Bool {
        return realm_object_delete(object)
    }
    
}
