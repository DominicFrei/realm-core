//
//  PropertyWrapper.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 29/12/2020.
//

import RealmC

@propertyWrapper final class Persisted {
    
    private var _wrappedValue = 0
    var realm: OpaquePointer!
    var tableKey: realm_table_key_t!
    var primaryKeyValue: realm_value_t!
    var columnKey: realm_col_key_t!
    
    var wrappedValue: Int {
        get {
            return _wrappedValue
        }
        set {
            _wrappedValue = newValue
        }
    }
    
    //    init(defaultValue: Int) {
    //        self.wrappedValue = defaultValue
    //    }
    
    //    private var value: Int
    //    private var isPrimaryKey = false
    
    
    //    var wrappedValue: Int
    //    {
    //        get {
    //            let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
    //            let object = realm_object_find_with_primary_key(realm, tableKey, primaryKeyValue, found)
    //            assert(found.pointee)
    //            assert((object != nil))
    //            assert(realm_object_is_valid(object))
    //
    //            let currentValue = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 1)
    //            let success = realm_get_value(object, columnKey, currentValue)
    //            assert(success)
    //
    //            return currentValue.pointee.integer as? Int ?? value
    //        }
    //        set {
    //            value = newValue
    //        }
    //    }
    
    //    init(isPrimaryKey: Bool, defaultValue: Int) {
    //        self.isPrimaryKey = isPrimaryKey
    //        value = defaultValue
    //    }
    
}
