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
    
}
