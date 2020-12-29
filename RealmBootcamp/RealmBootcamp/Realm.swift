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
    
    // TODO: Realm should not need to receive the classes by the user.
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
        var found = false
        var classInfo = realm_class_info_t()
        let success = realm_find_class(cRealm, type.classInfo().name, &found, &classInfo)
        assert(success)
        assert(found)
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
    
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }
    
    // TODO: Add a find without a primary key.
    func find<T: Persistable>(testClass: T, withPrimaryKey primaryKey: Int64) throws -> (OpaquePointer?, UnsafeMutablePointer<realm_col_key_t>, T) {
        
        let classInfo = retrieveClassInfo(for: testClass)
        let propertyKeys = retrievePropertyKeys(with: classInfo)
        let object = try findObject(with: classInfo, primaryKey: primaryKey)
        let values: [String: Encodable] = getValues(for: object, propertyKeys: propertyKeys, classInfo: classInfo)
        
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
        var outFound = false
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let success = realm_find_class(cRealm, name, &outFound, classInfo)
        assert(success)
        assert(String(cString: classInfo.pointee.name.data) == className)
        assert(String(cString: classInfo.pointee.primary_key.data) == "x")
        assert(classInfo.pointee.num_properties == testClass.properties().count)
        return classInfo
    }
    
    func findObject(with classInfo: UnsafeMutablePointer<realm_class_info_t>, primaryKey: Int64) throws -> OpaquePointer {
        var pkValue = realm_value_t()
        pkValue.integer = primaryKey
        pkValue.type = RLM_TYPE_INT // TODO: Allow all types.
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
//        let propertyInfo = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
//        realm_get_property(cRealm, tableKey, propertyKeys)
        assert(success)
        assert(outNumber.pointee == classInfo.pointee.num_properties)
        return propertyKeys
    }
    
    func getValues(for object: OpaquePointer, propertyKeys: UnsafeMutablePointer<realm_col_key_t>, classInfo: UnsafeMutablePointer<realm_class_info_t>) -> [String: Encodable] {
        let outValues = UnsafeMutablePointer<realm_value_t>.allocate(capacity: classInfo.pointee.num_properties)
        let success = realm_get_values(object, classInfo.pointee.num_properties, propertyKeys, outValues)
        assert(success)
        
        var values = [String: Encodable]()
        for i in 0..<classInfo.pointee.num_properties {
            let outPropertyInfo = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: 1)
            realm_get_property(cRealm, classInfo.pointee.key, propertyKeys.advanced(by: i).pointee, outPropertyInfo)
            // TODO: Add more types.
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
    
    func updateValues(for object: OpaquePointer, propertyKeys: UnsafeMutablePointer<realm_col_key_t>, newValues: [Any]) {
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
        
        let success = write {
            let success = realm_set_values(object, realmValues.count, propertyKeys, valuesAsPointer, false)
            assert(success)
        }
        assert(success)
    }
    
    func delete<T: Persistable>(_ object: OpaquePointer, of testClass: T) {
        var success = write {
            let success = realm_object_delete(object)
            assert(success)
        }
        assert(success)
        
        let classInfo = self.classInfo(for: testClass)
        var amount = size_t()
        success = realm_get_num_objects(cRealm, classInfo.key, &amount)
        assert(success)
        assert(amount == 0)
    }
    
}
