//
//  Schema.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

struct Schema {
    
    var cSchema: OpaquePointer
    
    init() {
        cSchema = CLayerAbstraction.createSchema()
    }
    
    init(classInfos: [ClassInfo], classProperties: [[PropertyInfo]]) throws {
        guard classInfos.count == classProperties.count else {
            throw RealmError.InvalidSchema
        }
        
        let unsafePointer = classProperties[0].withUnsafeBufferPointer({$0.baseAddress})
        let classPropertiesPointer = UnsafeMutablePointer<UnsafePointer<PropertyInfo>?>.allocate(capacity: classInfos[0].num_properties)
        for index in 0..<classInfos.count {
            classPropertiesPointer.advanced(by: index).pointee = unsafePointer
        }
        
        cSchema = try CLayerAbstraction.createSchema(classInfos: classInfos, propertyInfos: classProperties)
    }
    
}
