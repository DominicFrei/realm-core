//
//  Foo2.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 08/01/2021.
//

@testable import RealmBootcamp

class Foo2: Persistable2 {
    @Persisted(isPrimaryKey: true) var x: Int
    @Persisted var y: Int
    @Persisted var z: Int
    
    override func primaryKey() -> String {
        return "_x"
    }
}
