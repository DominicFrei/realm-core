//
//  Examples.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 31/12/2020.
//

// swiftlint:disable all
import RealmC


//func add<T: Object>(_ object: T) {
//        var classInfo = self.classInfo(T.self)
//        // add to schema
//        if classInfo == nil {
//            // set up new class info
//            var newClassInfo = realm_class_info_t()
//            newClassInfo.name = realm_string_t(data: strdup(String(describing: T.self)),
//                                               size: String(describing: T.self).count)
//            newClassInfo.num_properties = propertyInfos.count
//            let newProperties = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: propertyInfos.count)
//            // set up new property info
//            for index in 0..<propertyInfos.count {
//                // propertyInfos is something I've conjured up but don't want to give away just yet
//                newProperties.advanced(by: index).pointee = propertyInfos[index].0.handle
//            }
//            let allClasses = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: schema.objectSchemas.count + 1)
//            let allProperties = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: schema.objectSchemas.count + 1)
//            for index in 0..<self.schema.objectSchemas.count {
//                let (classInfo, properties) = self.schema.objectSchemas[index].handle
//                allClasses.advanced(by: index).pointee = classInfo
//                allProperties.advanced(by: index).pointee = UnsafePointer(properties)
//            }
//            allClasses.advanced(by: self.schema.objectSchemas.count).pointee = newClassInfo
//            allProperties.advanced(by: self.schema.objectSchemas.count).pointee = UnsafePointer(newProperties)
//            realm_commit(realm)
//            realm_set_schema(realm, realm_schema_new(allClasses, self.schema.objectSchemas.count + 1, allProperties))
//            realm_begin_write(realm)
//            // update the outClassInfo to contain the updated information
//            classInfo = self.classInfo(T.self)
//        }
//        // ... add object to realm
//    }






// new find
// add to schema
//        if classInfo == nil {
//            // set up new class info
//            let newClassInfo = UnmanagedClassInfo(T.self)
//            let newProperties = UnsafeMutablePointer<realm_property_info_t>.allocate(capacity: propertyInfos.count)
//            // set up new property info
//            for index in 0..<propertyInfos.count {
//                newProperties.advanced(by: index).pointee = propertyInfos[index].0.handle
//            }
//            let allClasses = UnsafeMutablePointer<realm_class_info_t>.allocate(capacity: schema.objectSchemas.count + 1)
//            let allProperties = UnsafeMutablePointer<UnsafePointer<realm_property_info_t>?>.allocate(capacity: schema.objectSchemas.count + 1)
//            for index in 0..<self.schema.objectSchemas.count {
//                let (classInfo, properties) = self.schema.objectSchemas[index].handle
//                allClasses.advanced(by: index).pointee = classInfo
//                allProperties.advanced(by: index).pointee = UnsafePointer(properties)
//            }
//            allClasses.advanced(by: self.schema.objectSchemas.count).pointee = newClassInfo.handle
//            allProperties.advanced(by: self.schema.objectSchemas.count).pointee = UnsafePointer(newProperties)
//            realm_commit(realm)
//            realm_set_schema(realm, realm_schema_new(allClasses, self.schema.objectSchemas.count + 1, allProperties))
//            realm_begin_write(realm)
//            // update the outClassInfo to contain the updated information
//            classInfo = self.classInfo(T.self)
//        }







// ==========================
// ==========================
// ==========================

//protocol ClassInfo {
//    var name: String { get }
//    var primaryKey: String { get }
//    var numProperties: Int { get }
//    var key: realm_table_key_t { get }
//    var flags: Int { get }
//    var handle: realm_class_info_t { get }
//}
//private struct ManagedClassInfo: ClassInfo {
//    private let realm: Realm
//    var handle: realm_class_info_t {
//        var classInfo = realm_class_info_t()
//        realm_get_class(realm.realm, key, &classInfo)
//        return classInfo
//    }
//    var name: String { String(cString: handle.name.data) }
//    var primaryKey: String { String(cString: handle.primary_key.data) }
//    var numProperties: Int { handle.num_properties }
//    let key: realm_table_key_t
//    var flags: Int { Int(handle.flags) }
//    init(_ realm: Realm, key: realm_table_key_t) {
//        self.realm = realm
//        self.key = key
//    }
//}
//private struct UnmanagedClassInfo: ClassInfo {
//    var name: String
//    var primaryKey: String = ""
//    var numProperties: Int = 0
//    var key = realm_table_key_t()
//    var flags: Int = 0
//    var handle: realm_class_info_t {
//        var classInfo = realm_class_info_t()
//        classInfo.name = realm_string_t(data: strdup(name), size: name.count)
//        classInfo.primary_key = realm_string_t(data: strdup(primaryKey), size: primaryKey.count)
//        classInfo.num_properties = numProperties
//        classInfo.flags = Int32(flags)
//        return classInfo
//    }
//    init<T: Object>(_ type: T.Type) {
//        let mirror = Mirror(reflecting: T())
//        self.name = String(describing: T.self)
//        for child in mirror.children {
//            switch child.value {
//            case let value as PropertyDeclaration:
//                numProperties += 1
//                if value.isPrimaryKey {
//                    primaryKey = child.label!
//                    flags = Int(RLM_PROPERTY_PRIMARY_KEY.rawValue)
//                }
//            default:
//                break
//            }
//        }
//    }
//}
