//
//  Configuration.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

struct Configuration {
    
    let cConfiguration: OpaquePointer
    
    init() throws {
        let uuid = UUID().uuidString
        let path = "\(uuid).realm"
        print(path)
        cConfiguration = realm_config_new()
        let realmPath = path.realmString()
        guard realm_config_set_path(cConfiguration, realmPath) else {
            throw RealmError.InvalidPath
        }
    }
    
}
