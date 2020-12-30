//
//  TableKey.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

struct TableKey {
    let key: UInt32
    
    init(_ tableKey: realm_table_key_t) {
        key = tableKey.table_key
    }
    
    func toCTableKey() -> realm_table_key_t {
        var cTableKey = realm_table_key_t()
        cTableKey.table_key = key
        return cTableKey
    }
}
