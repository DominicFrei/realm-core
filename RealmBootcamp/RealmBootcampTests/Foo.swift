//
//  Foo.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 08/01/2021.
//

@testable import RealmBootcamp

class Foo: Persistable {
    @Persisted(isPrimaryKey: true) var x: Int
    @Persisted var y: Int
    @Persisted var z: Int
}
