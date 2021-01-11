//
//  PropertyWrapper.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 29/12/2020.
//

import Foundation
import RealmC

//@propertyWrapper class Persisted {
//    
//    var _wrappedValue: Int = 0
//    var isPrimaryKey = false
//    var isManaged = false
//    
//    var container: Persistable?
//    var realm: OpaquePointer?
//    var tableKey: Int?
//    var columnKey: Int?
//    
//    var wrappedValue: Int {
//        get {
//            guard isManaged else {
//                return _wrappedValue
//            }
//            guard container != nil, realm != nil, tableKey != nil, columnKey != nil else {
//                return -1
//            }
//            guard !isPrimaryKey else {
//                return container!.primaryKeyValue!
//            }
//            
//            let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
//            var value = realm_value_t()
//            value.type = RLM_TYPE_INT
//            value.integer = Int64(container!.primaryKeyValue!)
//            var tableKeyC = realm_table_key_t()
//            tableKeyC.table_key = UInt32(tableKey!)
//            let object = realm_object_find_with_primary_key(realm, tableKeyC, value, found)
//            assert(found.pointee)
//            assert((object != nil))
//            assert(realm_object_is_valid(object))
//            
//            let currentValue = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 1)
//            var columnKeyC = realm_col_key_t()
//            columnKeyC.col_key = Int64(columnKey!)
//            let success = realm_get_value(object, columnKeyC, currentValue)
//            assert(success)
//            
//            return Int(currentValue.pointee.integer)
//        }
//        set {
//            guard isManaged else {
//                _wrappedValue = newValue
//                if isPrimaryKey {
//                    container!.primaryKeyValue = newValue
//                }
//                return
//            }
//            guard container != nil, realm != nil, tableKey != nil, columnKey != nil else {
//                return
//            }
//            guard !isPrimaryKey else {
//                // throw if already set
//                return
//            }
//            
//            saveValueToDatabase(newValue)
//        }
//    }
//    
//    init(isPrimaryKey: Bool = false) {
//        self.isPrimaryKey = isPrimaryKey
//    }
//    
//    func persist() {
//        isManaged = true
//        saveValueToDatabase(_wrappedValue)
//    }
//    
//    func saveValueToDatabase(_ newValue: Int) {
//        var primaryKey = realm_value_t()
//        primaryKey.type = RLM_TYPE_INT
//        primaryKey.integer = Int64(container!.primaryKeyValue!)
//        var tableKeyC = realm_table_key_t()
//        tableKeyC.table_key = UInt32(tableKey!)
//        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
//        let object = realm_object_find_with_primary_key(realm, tableKeyC, primaryKey, found)
//        
//        var columnKeyC = realm_col_key_t()
//        columnKeyC.col_key = Int64(columnKey!)
//        var value = realm_value_t()
//        value.type = RLM_TYPE_INT
//        value.integer = Int64(newValue)
//        realm_set_value(object, columnKeyC, value, false)
//    }
//    
//}
//
//@propertyWrapper final class PersistedString {
//    
//    var _wrappedValue: String = ""
//    var isManaged = false
//    
//    var container: Persistable?
//    var realm: OpaquePointer?
//    var tableKey: Int?
//    var columnKey: Int?
//    
//    var wrappedValue: String {
//        get {
//            guard isManaged else {
//                return _wrappedValue
//            }
//            guard container != nil, realm != nil, tableKey != nil, columnKey != nil else {
//                return "-1"
//            }
//            
//            let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
//            var value = realm_value_t()
//            value.type = RLM_TYPE_INT
//            value.integer = Int64(container!.primaryKeyValue!)
//            var tableKeyC = realm_table_key_t()
//            tableKeyC.table_key = UInt32(tableKey!)
//            let object = realm_object_find_with_primary_key(realm, tableKeyC, value, found)
//            assert(found.pointee)
//            assert((object != nil))
//            assert(realm_object_is_valid(object))
//            
//            let currentValue = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 1)
//            var columnKeyC = realm_col_key_t()
//            columnKeyC.col_key = Int64(columnKey!)
//            let success = realm_get_value(object, columnKeyC, currentValue)
//            assert(success)
//            
//            return currentValue.pointee.string.toString()
//        }
//        set {
//            guard isManaged else {
//                _wrappedValue = newValue
//                return
//            }
//            guard container != nil, realm != nil, tableKey != nil, columnKey != nil else {
//                return
//            }
//            
//            saveValueToDatabase(newValue)
//        }
//    }
//    
//    func persist() {
//        isManaged = true
//        saveValueToDatabase(_wrappedValue)
//    }
//    
//    func saveValueToDatabase(_ newValue: String) {
//        var primaryKey = realm_value_t()
//        primaryKey.type = RLM_TYPE_INT
//        primaryKey.integer = Int64(container!.primaryKeyValue!)
//        var tableKeyC = realm_table_key_t()
//        tableKeyC.table_key = UInt32(tableKey!)
//        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
//        let object = realm_object_find_with_primary_key(realm, tableKeyC, primaryKey, found)
//        
//        var columnKeyC = realm_col_key_t()
//        columnKeyC.col_key = Int64(columnKey!)
//        var value = realm_value_t()
//        value.type = RLM_TYPE_INT
//        value.string = newValue.realmString()
//        realm_set_value(object, columnKeyC, value, false)
//    }
//    
//}

protocol PersitableValue {}
extension Int: PersitableValue {}
extension String: PersitableValue {}

// swiftlint:disable force_cast
@propertyWrapper class PersistedGeneric<PersitableValue> {
    
    var _wrappedValue: PersitableValue?
    var isPrimaryKey = false
    var isManaged = false
    
    var container: Persistable?
    var realm: OpaquePointer?
    var tableKey: Int?
    var columnKey: Int?
    
    var wrappedValue: PersitableValue? {
        get {
            guard isManaged else {
                return _wrappedValue
            }
            guard container != nil, realm != nil, tableKey != nil, columnKey != nil else {
                switch _wrappedValue {
                case is Int:
                    return -1 as? PersitableValue
                case is String:
                    return "-1" as? PersitableValue
                default:
                    abort()
                }
            }
            guard !isPrimaryKey else {
                return container!.primaryKeyValue! as? PersitableValue
            }
            
            let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            var primaryKey = realm_value_t()
            primaryKey.type = RLM_TYPE_INT
            primaryKey.integer = Int64(container!.primaryKeyValue!)
            var tableKeyC = realm_table_key_t()
            tableKeyC.table_key = UInt32(tableKey!)
            let object = realm_object_find_with_primary_key(realm, tableKeyC, primaryKey, found)
            assert(found.pointee)
            assert((object != nil))
            assert(realm_object_is_valid(object))
            
            let currentValue = UnsafeMutablePointer<realm_value_t>.allocate(capacity: 1)
            var columnKeyC = realm_col_key_t()
            columnKeyC.col_key = Int64(columnKey!)
            let success = realm_get_value(object, columnKeyC, currentValue)
            assert(success)
            
            switch _wrappedValue {
            case is Int?:
                return Int(currentValue.pointee.integer) as? PersitableValue
            case is String?:
                return currentValue.pointee.string.toString() as? PersitableValue
            default:
                abort()
            }
        }
        set {
            guard isManaged else {
                _wrappedValue = newValue
                if isPrimaryKey {
                    container!.primaryKeyValue = (newValue as! Int)
                }
                return
            }
            guard container != nil, realm != nil, tableKey != nil, columnKey != nil else {
                abort()
            }
            guard !isPrimaryKey else {
                // throw if already set
                return
            }
            
            saveValueToDatabase(newValue)
        }
    }
    
    init(isPrimaryKey: Bool? = false, defaultValue: PersitableValue? = nil) {
        self.isPrimaryKey = isPrimaryKey ?? false
        if let defaultValue = defaultValue {
            _wrappedValue = defaultValue
        }
    }
    
    func persist() {
        isManaged = true
        saveValueToDatabase(_wrappedValue)
    }
    
    func saveValueToDatabase(_ newValue: PersitableValue?) {
        guard newValue != nil else {
            return
        }
        var primaryKey = realm_value_t()
        primaryKey.type = RLM_TYPE_INT
        primaryKey.integer = Int64(container!.primaryKeyValue!)
        var tableKeyC = realm_table_key_t()
        tableKeyC.table_key = UInt32(tableKey!)
        let found = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let object = realm_object_find_with_primary_key(realm, tableKeyC, primaryKey, found)
        
        var columnKeyC = realm_col_key_t()
        columnKeyC.col_key = Int64(columnKey!)
        var value = realm_value_t()
        switch newValue {
        case let newValueCasted as Int:
            value.type = RLM_TYPE_INT
            value.integer = Int64(newValueCasted)
        case let newValueCasted as String:
            value.type = RLM_TYPE_STRING
            value.string = newValueCasted.realmString()
        default:
            abort()
        }
        guard realm_set_value(object, columnKeyC, value, false) else {
            return
        }
    }
    
}
