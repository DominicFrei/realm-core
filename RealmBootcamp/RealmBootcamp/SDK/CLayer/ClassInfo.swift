//
//  ClassInfo.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

struct ClassInfo {
    let name: String
    let primary_key: String
    let num_properties: Int
    let num_computed_properties: Int
    let key: TableKey
    let flags: Int32
    
    init(_ cClassInfo: realm_class_info_t) {
        name = cClassInfo.name.toString()
        primary_key = cClassInfo.primary_key.toString()
        num_properties = cClassInfo.num_properties
        num_computed_properties = cClassInfo.num_computed_properties
        key = TableKey(cClassInfo.key)
        flags = cClassInfo.flags
    }
    
    func toCClassInfo() -> realm_class_info_t {
        var cClassInfo = realm_class_info_t()
        cClassInfo.name = name.realmString()
        cClassInfo.primary_key = primary_key.realmString()
        cClassInfo.num_properties = num_properties
        cClassInfo.num_computed_properties = num_computed_properties
        cClassInfo.key = key.toCTableKey()
        cClassInfo.flags = flags
        return cClassInfo
    }
}
