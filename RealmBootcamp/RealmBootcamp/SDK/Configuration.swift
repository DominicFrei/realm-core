//
//  Configuration.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

struct Configuration {
    
    let cConfig: OpaquePointer
    
    let path: String
    
    init(path: String? = nil) throws {
        if let path = path {
            self.path = path
        } else {
            let uuid = UUID().uuidString
            self.path = "\(uuid).realm"
        }
        print(self.path)
        cConfig = realm_config_new()
        let realmPath = self.path.realmString()
        guard realm_config_set_path(cConfig, realmPath) else {
            throw RealmError.InvalidPath
        }
    }
    
    func apply(schema: Schema, mode: realm_schema_mode_e, version: UInt64) {
        var success: Bool
        success = realm_config_set_schema(cConfig, schema.cSchema)
        assert(success)
        success = realm_config_set_schema_mode(cConfig, mode)
        assert(success)
        success = realm_config_set_schema_version(cConfig, version)
        assert(success)
    }
    
}
