//
//  Schema.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

struct Schema {
    
    var cSchema: OpaquePointer
    
    private let realm: Realm?
    
    init(realm: Realm? = nil) {
        cSchema = realm_schema_new(nil, 0, nil)
        self.realm = realm
    }
    
    init(classInfos: UnsafeMutablePointer<realm_class_info_t>, count: Int, classProperties: UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>, realm: Realm) throws {
        guard let schema = realm_schema_new(classInfos, count, classProperties) else {
            throw RealmError.InvalidSchema
        }
        self.cSchema = schema
        self.realm = realm
    }
    
    var objectSchemas: [ObjectSchema] {
        guard let realm = self.realm else {
            return [ObjectSchema]()
        }
        // fetch number of tables
        let numClasses = realm_get_num_classes(realm.cRealm)
        // allocate an array to contain the classes given a table count
        let outKeys = UnsafeMutablePointer<realm_table_key_t>.allocate(capacity: numClasses)
        realm_get_class_keys(realm.cRealm, outKeys, -1, nil)
        // map the class keys to the ObjectSchema struct
        return (0..<numClasses).map { index in
            ObjectSchema(realm, key: outKeys.advanced(by: index).pointee)
        }
    }
    
}
