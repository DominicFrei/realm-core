//
//  Bar.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 22/12/2020.
//

@testable import RealmBootcamp

struct Bar: Persistable {
    var x = 0
    var y = 0
    var z = 0
    var primaryKey: String {
        return "x"
    }
}
