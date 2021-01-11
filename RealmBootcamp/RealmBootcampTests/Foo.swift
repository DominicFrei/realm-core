//
//  Foo.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 08/01/2021.
//

@testable import RealmBootcamp

class Foo: Persistable {
    @PersistedGeneric<Int>(isPrimaryKey: true) var x
    @PersistedGeneric<Int> var y
    @PersistedGeneric<Int> var z
}
