//
//  PropertyInfo.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

enum PropertyType: UInt32 {
    case Int = 0
    case Bool = 1
    case String = 2
    case Binary = 4
    case Mixed = 6
    case Timestamp = 8
    case Float = 9
    case Double = 10
    case Decimal128 = 11
    case Object = 12
    case LinkedObject = 14
    case ObjectId = 15
    case Uuid = 17
}

enum CollectionType: UInt32 {
    case None = 0
    case List = 1
    case Set = 2
    case Dictionary = 4
}

struct PropertyInfo {
    let name: String
    let public_name: String
    let type: PropertyType
    let collectionType: CollectionType
    let linkTarget: String
    let linkOriginPropertyName: String
    let key: ColumnKey
    let flags: Int32
    
    init?(_ cPropertyInfo: realm_property_info_t) {
        name = cPropertyInfo.name.toString()
        public_name = cPropertyInfo.public_name.toString()
        guard let cType = PropertyType(rawValue: cPropertyInfo.type.rawValue) else {
            return nil
        }
        type = cType
        guard let cCollectionType = CollectionType(rawValue: cPropertyInfo.collection_type.rawValue) else {
            return nil
        }
        collectionType = cCollectionType
        linkTarget = cPropertyInfo.link_target.toString()
        linkOriginPropertyName = cPropertyInfo.link_origin_property_name.toString()
        key = ColumnKey(cPropertyInfo.key)
        flags = cPropertyInfo.flags
    }
    
    func toCPropertyInfo() -> realm_property_info_t {
        var cPropertyInfo = realm_property_info_t()
        cPropertyInfo.name = name.realmString()
        cPropertyInfo.public_name = public_name.realmString()
        cPropertyInfo.type = realm_property_type_e(type.rawValue)
        cPropertyInfo.collection_type = realm_collection_type_e(rawValue: collectionType.rawValue)
        cPropertyInfo.link_target = linkTarget.realmString()
        cPropertyInfo.link_origin_property_name = linkOriginPropertyName.realmString()
        cPropertyInfo.key = key.toCColumnKey()
        cPropertyInfo.flags = flags
        return cPropertyInfo
    }
}
