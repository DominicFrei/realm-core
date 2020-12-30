//
//  String+RealmString.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

extension String {
    func realmString() -> realm_string {
        realm_string(data: strdup(self), size: self.count)
    }
}
