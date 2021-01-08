//
//  PropertyWrapper.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 29/12/2020.
//

import RealmC

@propertyWrapper final class Persisted {
    
    private var isPrimaryKey = false
    
    var realm: OpaquePointer!
    var tableKey: realm_table_key_t!
    var primaryKeyValue: Int!
    var columnKey: realm_col_key_t!
    
    var wrappedValue: Int {
        get {
            guard !isPrimaryKey else {
                return primaryKeyValue
            }
            
            let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            var primaryKey = realm_value_t()
            primaryKey.type = RLM_TYPE_INT
            primaryKey.integer = Int64(primaryKeyValue)
            let object = realm_object_find_with_primary_key(realm, tableKey, primaryKey, found)
            assert(found.pointee)
            assert((object != nil))
            assert(realm_object_is_valid(object))
            
            let currentValue = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 1)
            let success = realm_get_value(object, columnKey, currentValue)
            assert(success)
            
            return Int(currentValue.pointee.integer)
        }
        set {
            guard !isPrimaryKey else {
                primaryKeyValue = newValue
                return
            }
        }
    }
    
    init(isPrimaryKey: Bool = false) {
        self.isPrimaryKey = isPrimaryKey
    }
    
}
