//
//  Persistable.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

class Persistable {
    
    var realm: OpaquePointer?
    var tableKey: realm_table_key_t?
    var primaryKeyValue: Int?
    
    required init() {
        let mirror = Mirror(reflecting: self)
        let properties = mirror.children.map { Property(label: $0.label!, value: $0.value) }
        for property in properties {
            switch property.value {
            case let value as Persisted:
                value.container = self
            default:
                abort()
            }
        }
    }
    
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
