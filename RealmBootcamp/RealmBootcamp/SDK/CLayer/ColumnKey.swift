//
//  ColumnKey.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

import RealmC

struct ColumnKey {
    let key: Int
    
    init(_ columnKey: realm_col_key_t) {
        key = Int(columnKey.col_key)
    }
    
    func toCColumnKey() -> realm_col_key_t {
        var cColumnKey = realm_col_key_t()
        cColumnKey.col_key = Int64(key)
        return cColumnKey
    }
}
