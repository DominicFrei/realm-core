//
//  String+RealmString.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

extension realm_string_t {
    func toString() -> String {
        if let data = self.data {
            return String(cString: data)
        } else {
            return ""
        }
    }
}

extension String {
    func realmString() -> realm_string_t {
        realm_string_t(data: strdup(self), size: self.count)
    }
}
