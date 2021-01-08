//
//  Persistable.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

protocol Persistable: Codable, Equatable {
    var primaryKey: String { get }
    func isValid() -> Bool
}

extension Persistable {
    
    func properties() -> [Property] {
        let mirror = Mirror(reflecting: self)
        let properties = mirror.children.map { Property(label: $0.label!, value: $0.value) }
        return properties
    }
    
    func typeName() -> String {
        return String(describing: Self.self)
    }
    
    func isValid() -> Bool {
        return false
    }
    
    func primaryKeyValue() throws -> Int {
        guard let primaryKeyValue = self.properties().filter({ $0.label == self.primaryKey }).first?.value as? Int else {
            throw RealmError.PrimaryKeyViolation
        }
        return primaryKeyValue
    }
    
    func classInfo() -> ClassInfo {
        let primaryKey = self.primaryKey.realmString()
        var classInfo = realm_class_info_t()
        classInfo.name = typeName().realmString()
        classInfo.primary_key = primaryKey
        classInfo.num_properties = properties().count
        return ClassInfo(classInfo)
    }
    
    func classProperties() throws -> [PropertyInfo] {
        var classProperties = [PropertyInfo]()
        for property in properties() {
            let name = property.label
            var type = realm_property_type_e(rawValue: 0)
            switch property.value {
            case is Int:
                type = RLM_PROPERTY_TYPE_INT
            case is String:
                type = RLM_PROPERTY_TYPE_STRING
            default:
                break
            }
            let isPrimaryKey = self.primaryKey == property.label
            let key = realm_col_key_t()
            let propertyInfo = PropertyInfo(name: name, type: type, isPrimaryKey: isPrimaryKey, key: key)
            classProperties.append(propertyInfo)
        }
        return classProperties
    }
    
    static func classInfoo(in realm: Realm) -> ClassInfo? {
        let didFindClass = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let didSucceed = realm_find_class(realm.cRealm, String(describing: self.self).realmString(), didFindClass, classInfo)
        guard didSucceed && didFindClass.pointee else {
            return nil
        }
        let mappedClassInfo = ClassInfo(classInfo.pointee)
        return mappedClassInfo
    }
    
    func tableKey(in realm: Realm) -> realm_table_key_t? {
        let didFindClass = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let didSucceed = realm_find_class(realm.cRealm, typeName().realmString(), didFindClass, classInfo)
        guard didSucceed && didFindClass.pointee else {
            return nil
        }
        return classInfo.pointee.key
    }
    
    //    static func retrievePropertyKeys(in realm: Realm) throws -> [realm_col_key_t] {
    //        guard let classInfo = classInfoo(in: realm) else {
    //            throw RealmError.ClassNotFound
    //        }
    //        let propertyKeys = UnsafeMutablePointer<realm_col_key_t>.allocate(capacity: classInfo.num_properties)
    //        let outNumber = UnsafeMutablePointer<size_t>.allocate(capacity: 1)
    //        guard let tableKey = tableKey(in: realm) else {
    //            throw RealmError.ClassNotFound
    //        }
    //        guard realm_get_property_keys(realm.cRealm, tableKey, propertyKeys, classInfo.num_properties, outNumber) else {
    //            throw RealmError.PropertiesNotFound
    //        }
    //        var columnKeys = [realm_col_key_t]()
    //        for i in 0..<classInfo().num_properties {
    //            let columnKey = propertyKeys.advanced(by: i).pointee
    //            columnKeys.append(columnKey)
    //        }
    //        return columnKeys
    //    }
    
}

class Persistable2 {
    
    init() {}
    
    func primaryKey() -> String {
        return ""
    }
    
    func properties() -> [Property] {
        let mirror = Mirror(reflecting: self)
        let properties = mirror.children.map { Property(label: $0.label!, value: $0.value) }
        return properties
    }
    
    func typeName() -> String {
        return String(describing: Self.self)
    }
    
    func isValid() -> Bool {
        return false
    }
    
    func primaryKeyValue() throws -> Int {
        let properties = self.properties()
        let filteredProperties = properties.filter({ $0.label == self.primaryKey() })
        let firstResult = filteredProperties.first
        let value = firstResult?.value
        guard let primaryKeyValue = value as? Persisted else {
            throw RealmError.PrimaryKeyViolation
        }
        return primaryKeyValue.wrappedValue
    }
    
    func classInfo() -> ClassInfo {
        let primaryKey = self.primaryKey().realmString()
        var classInfo = realm_class_info_t()
        classInfo.name = typeName().realmString()
        classInfo.primary_key = primaryKey
        classInfo.num_properties = properties().count
        return ClassInfo(classInfo)
    }
    
    func classProperties() throws -> [PropertyInfo] {
        var classProperties = [PropertyInfo]()
        for property in properties() {
            let name = property.label
            var type = realm_property_type_e(rawValue: 0)
            switch property.value {
            case is Int:
                type = RLM_PROPERTY_TYPE_INT
            case is String:
                type = RLM_PROPERTY_TYPE_STRING
            default:
                break
            }
            let isPrimaryKey = self.primaryKey() == property.label
            let key = realm_col_key_t()
            let propertyInfo = PropertyInfo(name: name, type: type, isPrimaryKey: isPrimaryKey, key: key)
            classProperties.append(propertyInfo)
        }
        return classProperties
    }
    
    static func classInfoo(in realm: Realm) -> ClassInfo? {
        let didFindClass = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let didSucceed = realm_find_class(realm.cRealm, String(describing: self.self).realmString(), didFindClass, classInfo)
        guard didSucceed && didFindClass.pointee else {
            return nil
        }
        let mappedClassInfo = ClassInfo(classInfo.pointee)
        return mappedClassInfo
    }
    
    func tableKey(in realm: Realm) -> realm_table_key_t? {
        let didFindClass = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
        let classInfo = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: 1)
        let didSucceed = realm_find_class(realm.cRealm, typeName().realmString(), didFindClass, classInfo)
        guard didSucceed && didFindClass.pointee else {
            return nil
        }
        return classInfo.pointee.key
    }
    
}
