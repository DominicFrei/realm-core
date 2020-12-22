//
//  Realm.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

struct Realm {
    
    let configuration: Configuration
    let cRealm: OpaquePointer
    
    init(configuration: Configuration) {
        self.configuration = configuration
        cRealm = realm_open(configuration.cConfig)
    }
    
    func write(_ transaction: () -> Void) -> Bool {
        let beginWriteSuccess = realm_begin_write(cRealm)
        transaction()
        let commitSuccess = realm_commit(cRealm)
        return beginWriteSuccess && commitSuccess
    }
    
    func classInfo<T: Persistable>(for type: T) -> realm_class_info_t {
        var amount = size_t()
        var found = false
        var classInfo = realm_class_info_t()
        var success = realm_find_class(cRealm, type.classInfo().name, &found, &classInfo)
        assert(success)
        success = realm_get_num_objects(cRealm, classInfo.key, &amount)
        assert(success)
        return classInfo
    }
    
}
