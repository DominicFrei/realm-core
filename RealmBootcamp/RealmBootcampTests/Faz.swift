//
//  Faz.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 23/12/2020.
//

@testable import RealmBootcamp

struct Faz: Persistable {
    var x = 0
    var y = 0
    var z = 0
    var a = ""
    var b = ""
    var primaryKey: String {
        return "x"
    }
}
