//
//  Baz.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 22/12/2020.
//

@testable import RealmBootcamp

struct Baz: Persistable {
    let x: Int
    let y: Int
    let z: String
    var primaryKey: String {
        return "x"
    }
}
