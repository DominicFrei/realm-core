//
//  Persistable+CLayer.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

extension Persistable {
    
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
            guard let mappedPropertyInfo = PropertyInfo(propertyInfo) else {
                throw RealmError.ClassNotFound
            }
            classProperties.append(mappedPropertyInfo)
        }
        return classProperties
    }
    
}
