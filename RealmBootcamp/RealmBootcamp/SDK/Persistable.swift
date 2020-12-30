//
//  Persistable.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

protocol Persistable: Codable {
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
    
    func classInfo() -> realm_class_info {
        let primaryKey = self.primaryKey.realmString()
        var classInfo = realm_class_info()
        classInfo.name = typeName().realmString()
        classInfo.primary_key = primaryKey
        classInfo.num_properties = properties().count
        return classInfo
    }
    
    func classProperties() -> [realm_property_info_t] {
        var classProperties = [realm_property_info_t]()
        for property in properties() {
            let propertyName = property.label
            var propertyInfo = realm_property_info_t()
            propertyInfo.name = propertyName.realmString()
            propertyInfo.public_name = "".realmString()
            
            switch property.value {
            case is Int:
                propertyInfo.type = RLM_PROPERTY_TYPE_INT
            case is String:
                propertyInfo.type = RLM_PROPERTY_TYPE_STRING
            default:
                break
            }
            
            if self.primaryKey == property.label {
                propertyInfo.flags = Int32(RLM_PROPERTY_PRIMARY_KEY.rawValue)
            } else {
                propertyInfo.flags = Int32(RLM_PROPERTY_NORMAL.rawValue)
            }
            classProperties.append(propertyInfo)
        }
        return classProperties
    }
    
    func isValid() -> Bool {
        return false
    }
    
}
