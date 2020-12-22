//
//  Schema.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

struct Schema {
    
    let classInfos: [realm_class_info]
    let classProperties: [[realm_property_info_t]]
    var cSchema: OpaquePointer
    
    init?<T: Persistable>(classes: [T]) {
        let classInfos: [realm_class_info] = classes.map{$0.classInfo()}
        let classProperties: [[realm_property_info_t]] = classes.map{$0.classProperties()}
        self.init(classInfos: classInfos, classProperties: classProperties)
    }
    
    init?(classInfos: [realm_class_info], classProperties: [[realm_property_info_t]]) {
        
        guard classInfos.count == classProperties.count else {
            return nil
        }
        
        self.classInfos = classInfos
        self.classProperties = classProperties
        let unsafePointer = classProperties[0].withUnsafeBufferPointer({$0.baseAddress})
        let classPropertiesPointer = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: classInfos[0].num_properties)
        for index in 0..<classInfos.count {
            classPropertiesPointer.advanced(by: index).pointee = unsafePointer
        }
        cSchema = realm_schema_new(classInfos, classInfos.count, classPropertiesPointer)
    }
    
}
