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
    
}
