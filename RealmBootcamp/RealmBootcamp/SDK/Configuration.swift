//
//  Configuration.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

struct Configuration {
    
    let cConfiguration: OpaquePointer
    
    init() throws {
        let uuid = UUID().uuidString
        let path = "\(uuid).realm"
        print(path)
        cConfiguration = CLayerAbstraction.createConfiguration()
        try CLayerAbstraction.setPath(path, to: cConfiguration)
    }
    
    // TODO: Works without?
//    func apply(schema: Schema, mode: realm_schema_mode_e, version: UInt64) {
//        var success: Bool
//        success = realm_config_set_schema(cConfiguration, schema.cSchema)
//        assert(success)
//        success = realm_config_set_schema_mode(cConfiguration, mode)
//        assert(success)
//        success = realm_config_set_schema_version(cConfiguration, version)
//        assert(success)
//    }
    
}
