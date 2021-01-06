//
//  ObjectSchema.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 31/12/2020.
//

import RealmC

public struct ObjectSchema {
    
    lazy var name: String = String(cString: classInfo.name.data)
    var properties: [PropertyInfo] {
        // fetch column count
        var colCount = 0
        realm_get_property_keys(realm.cRealm, classInfo.key, nil, -1, &colCount)
        // allocate an array to contain the properties given a column count
        let outProperties = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: colCount)
        realm_get_class_properties(realm.cRealm, key, outProperties, -1, &colCount)
        // map each property to the PropertyInfo struct
        return (0..<colCount).map { index in
            var propertyInfo = realm_property_info_t()
            realm_get_property(realm.cRealm, key, outProperties.advanced(by: index).pointee.key, &propertyInfo)
            let mappedPropertyInfo = PropertyInfo(name: String(cString: propertyInfo.name.data),
                                            type: propertyInfo.type,
                                            isPrimaryKey: propertyInfo.flags == RLM_PROPERTY_PRIMARY_KEY.rawValue,
                                            key: outProperties.advanced(by: index).pointee.key)
            return mappedPropertyInfo
        }
    }
    var handle: (realm_class_info_t, UnsafeMutablePointer<realm_property_info_t>) {
        let properties = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: self.properties.count)
        for index in 0..<self.properties.count {
            let property = self.properties[index]
            var propertyInfo = realm_property_info_t()
            propertyInfo.name = realm_string(data: strdup(property.name), size: property.name.count)
            propertyInfo.flags = Int32(property.isPrimaryKey ? RLM_PROPERTY_PRIMARY_KEY.rawValue : RLM_PROPERTY_NORMAL.rawValue)
            propertyInfo.key = property.key
            propertyInfo.type = property.type
            properties.advanced(by: index).pointee = propertyInfo
        }
        return (classInfo, properties)
    }
    
    private let realm: Realm
    private let key: realm_table_key_t
    private var classInfo: realm_class_info_t {
        var classInfo = realm_class_info_t()
        realm_get_class(realm.cRealm, key, &classInfo)
        return classInfo
    }
    
    internal init(_ realm: Realm, key: realm_table_key_t) {
        self.realm = realm
        self.key = key
    }
}
