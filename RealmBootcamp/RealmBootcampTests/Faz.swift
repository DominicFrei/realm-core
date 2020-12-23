//
//  Faz.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 23/12/2020.
//

@testable import RealmBootcamp

struct Faz: Persistable {
    let x: Int
    let y: Int
    let z: Int
    let a: String
    let b: String
    var primaryKey: String {
        return "x"
    }
}

