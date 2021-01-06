//
//  PropertyInfo.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

struct PropertyInfo {
    let name: String
    let type: realm_property_type_e
    let isPrimaryKey: Bool
    let key: realm_col_key_t
    
    var handle: realm_property_info_t {
        var propertyInfo = realm_property_info_t()
        propertyInfo.name = realm_string(data: strdup(name), size: name.count)
        propertyInfo.public_name = "".realmString()
        propertyInfo.type = type
        propertyInfo.key = key
        propertyInfo.link_target = "".realmString()
        propertyInfo.link_origin_property_name = "".realmString()
        propertyInfo.flags = Int32(isPrimaryKey ? RLM_PROPERTY_PRIMARY_KEY.rawValue : RLM_PROPERTY_NORMAL.rawValue)
        return propertyInfo
    }

}
