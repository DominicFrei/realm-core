//
//  Realm.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

class Realm {
    
    struct EncodableWrapper: Encodable {
        let wrapped: Encodable
        func encode(to encoder: Encoder) throws {
            try self.wrapped.encode(to: encoder)
        }
    }
    
    let cRealm: OpaquePointer
    var configuration: Configuration
    var schema: Schema
    
    init() throws {
        configuration = try Configuration()
        cRealm = CLayerAbstraction.openRealm(with: configuration.cConfiguration)
        schema = Schema()
    }
    
    func write(_ transaction: () throws -> Void) throws {
        try CLayerAbstraction.startTransaction(on: cRealm)
        try transaction()
        try CLayerAbstraction.endTransaction(on: cRealm)
    }
    
    func add<T: Persistable>(_ object: T) throws {
        try addTypeIfNecessary(object)
        try CLayerAbstraction.create(object, in: self.cRealm)
    }
    
//    func addTypeIfNecessary<T: Persistable>(_ type: T) throws {
//        let classInfo = CLayerAbstraction.find(type.typeName(), in: cRealm)
//        guard classInfo == nil else {
//            return
//        }
//
//        var (classInfos, classProperties) = try getCurrentClassAndPropertyInfo()
//
//        // Add the new class to the existing class and property info.
//        classInfos.append(type.classInfo())
//        classProperties.append(try type.classProperties())
//
//        // Set the new schema in the current realm.
//        schema = try Schema(classInfos: classInfos, propertyInfos: classProperties, realm: self)
//        // TODO: Rework to not just commi and start write again but save and execute whole transaction after add.
//        try CLayerAbstraction.endTransaction(on: cRealm)
//        try CLayerAbstraction.setSchema(schema.cSchema, for: cRealm)
//        try CLayerAbstraction.setSchema(schema.cSchema, in: configuration.cConfiguration)
//        self.schema.cSchema = CLayerAbstraction.getSchema(for: cRealm)
//        try CLayerAbstraction.startTransaction(on: cRealm)
//    }
    
    func addTypeIfNecessary<T: Persistable>(_ type: T) throws {
        let classInfo = CLayerAbstraction.find(type.typeName(), in: cRealm)
        guard classInfo == nil else {
            return
        }

        //        var (classInfos, classProperties): ([ClassInfo], [[PropertyInfo]]) = try getCurrentClassAndPropertyInfo()

        let existingClassesCount = schema.objectSchemas.count
        let classInfos = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: existingClassesCount + 1)
        let classProperties = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: existingClassesCount + 1)

        for i in 0..<existingClassesCount {
            let (classInfo, classProperty): (realm_class_info_t, UnsafeMutablePointer<realm_property_info_t>) = schema.objectSchemas[i].handle
            classInfos.advanced(by: i).pointee = classInfo
            classProperties.advanced(by: i).pointee = UnsafePointer(classProperty)
        }

        // Add the new class to the existing class and property info.
        classInfos.advanced(by: existingClassesCount).pointee = type.classInfo().toCClassInfo()
        let classPropertyArray: [PropertyInfo] = try type.classProperties()
        let mappedProperties: [realm_property_info_t] = classPropertyArray.map {$0.handle}
        let propertiesAsUnsafePointer: UnsafePointer<realm_property_info_t> = mappedProperties.withUnsafeBufferPointer({$0.baseAddress!})
        classProperties.advanced(by: existingClassesCount).pointee = propertiesAsUnsafePointer

        // Set the new schema in the current realm.
        schema = try Schema(classInfos: classInfos, count: existingClassesCount + 1, classProperties: classProperties, realm: self)
        // TODO: Rework to not just commit and start write again but save and execute whole transaction after add.
        try CLayerAbstraction.endTransaction(on: cRealm)
        try CLayerAbstraction.setSchema(schema.cSchema, for: cRealm)
        try CLayerAbstraction.setSchema(schema.cSchema, in: configuration.cConfiguration)
        schema.cSchema = CLayerAbstraction.getSchema(for: cRealm)
        try CLayerAbstraction.startTransaction(on: cRealm)
    }
    
    func getCurrentClassAndPropertyInfo() throws -> (classes: [ClassInfo], properties: [[PropertyInfo]]) {
        let classKeys = try CLayerAbstraction.tableKeys(from: cRealm)
        var classInfos = [ClassInfo]()
        var classProperties = [[PropertyInfo]]()
        for i in 0..<classKeys.count {
            let tableKey = classKeys[i]
            let classInfo = try CLayerAbstraction.classInfo(for: tableKey, from: cRealm)
            classInfos.append(ClassInfo(classInfo))
            let properties = try CLayerAbstraction.propertyInfo(for: classInfo, in: cRealm)
            classProperties.append(properties)
        }
        return (classInfos, classProperties)
    }
    
    func find<T: Persistable>(_ type: T.Type, withPrimaryKey primaryKey: Int) throws -> T {
        guard let classInfo = CLayerAbstraction.find(String(describing: type), in: cRealm) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try CLayerAbstraction.retrievePropertyKeys(with: classInfo, in: cRealm)
        let object = try CLayerAbstraction.findObject(with: classInfo, primaryKey: primaryKey, in: cRealm)
        let values: [String: Encodable] = try CLayerAbstraction.getValues(for: object, propertyKeys: propertyKeys, classInfo: classInfo, in: cRealm)
        
        let wrappedDict = values.mapValues(EncodableWrapper.init(wrapped:))
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        var model: T!
        
        let jsonData = try jsonEncoder.encode(wrappedDict)
        let json = String(decoding: jsonData, as: UTF8.self)
        let data = json.data(using: .utf8)
        model = decodeData(data!)
        
        return model!
    }
    
    func decodeData<T: Persistable>(_ data: Data) -> T? {
        var model: T?
        do {
            model = try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            print(error.localizedDescription)
            assert(false)
        }
        return model
    }
    
    func updateValues<T: Persistable>(objectOfType type: T.Type, withPrimaryKey primaryKey: Int, newValues: [Any]) throws {
        guard let classInfo = CLayerAbstraction.find(String(describing: type), in: cRealm) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try CLayerAbstraction.retrievePropertyKeys(with: classInfo, in: cRealm)
        let object = try CLayerAbstraction.findObject(with: classInfo, primaryKey: primaryKey, in: cRealm)
        return try CLayerAbstraction.updateValues(for: object, propertyKeys: propertyKeys, newValues: newValues)
    }
    
    func delete<T: Persistable>(_ object: T) throws {
        guard let classInfo = CLayerAbstraction.find(object.typeName(), in: cRealm) else {
            throw RealmError.ClassNotFound
        }
        let primaryKeyValue = try object.primaryKeyValue()
        let object = try CLayerAbstraction.findObject(with: classInfo, primaryKey: primaryKeyValue, in: cRealm)
        try CLayerAbstraction.delete(object)
    }
    
}
