//
//  Realm.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

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
        cRealm = CLayerAbstraction.realm(for: configuration.cConfiguration)
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
    
    func addTypeIfNecessary<T: Persistable>(_ type: T) throws {
        let classInfo = CLayerAbstraction.find(type.typeName(), in: cRealm)
        guard classInfo == nil else {
            return
        }
        
        var (classInfos, classProperties) = try getCurrentClassAndPropertyInfo()
        
        // Add the new class to the existing class and property info.
        classInfos.append(type.classInfo())
        classProperties.append(try type.classProperties())
        
        // Set the new schema in the current realm.
        schema = try Schema(classInfos: classInfos, classProperties: classProperties)
        // TODO: Rework to not just commi and start write again but save and execute whole transaction after add.
        try CLayerAbstraction.endTransaction(on: cRealm)
        try CLayerAbstraction.setSchema(schema.cSchema, for: cRealm)
        try CLayerAbstraction.setSchema(schema.cSchema, in: configuration.cConfiguration)
        self.schema.cSchema = CLayerAbstraction.getSchema(for: cRealm)
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
    
    func find<T: Persistable>(objectOfType type: T, withPrimaryKey primaryKey: Int) throws -> T {
        guard let classInfo = CLayerAbstraction.find(type.typeName(), in: cRealm) else {
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
        } catch {
            assert(false)
        }
        return model
    }
    
    func updateValues<T: Persistable>(objectOfType type: T, withPrimaryKey primaryKey: Int, newValues: [Any]) throws {
        guard let classInfo = CLayerAbstraction.find(type.typeName(), in: cRealm) else {
            throw RealmError.ClassNotFound
        }
        let propertyKeys = try CLayerAbstraction.retrievePropertyKeys(with: classInfo, in: cRealm)
        let object = try CLayerAbstraction.findObject(with: classInfo, primaryKey: primaryKey, in: cRealm)
        return try CLayerAbstraction.updateValues(for: object, propertyKeys: propertyKeys, newValues: newValues)
    }
    
    func delete<T: Persistable>(_ object: T, primaryKey: Int) throws {
        guard let classInfo = CLayerAbstraction.find(object.typeName(), in: cRealm) else {
            throw RealmError.ClassNotFound
        }
        let object = try CLayerAbstraction.findObject(with: classInfo, primaryKey: primaryKey, in: cRealm)
        try CLayerAbstraction.delete(object)
    }
    
}
