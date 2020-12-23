//
//  Bar.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 22/12/2020.
//

@testable import RealmBootcamp

struct Bar: Persistable {
    let x: Int
    let y: Int
    let z: Int
    var primaryKey: String {
        return "x"
    }
}
