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
    
}
