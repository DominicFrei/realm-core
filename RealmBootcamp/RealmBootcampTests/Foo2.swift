//
//  Foo2.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 08/01/2021.
//

@testable import RealmBootcamp

class Foo2: Persistable2 {
//    @Persisted<Int>(isPrimaryKey: true, defaultValue: 0) var x: Int
//    @Persisted<Int>(isPrimaryKey: false, defaultValue: 0) var y: Int
//    @Persisted<Int>(isPrimaryKey: false, defaultValue: 0) var z: Int
//    @Persisted var x: Int
//    @Persisted var y: Int
//    @Persisted var z: Int
    @Persisted var x: Int
    @Persisted var y: Int
    @Persisted var z: Int
    
    override func primaryKey() -> String {
        return "_x"
      }
    
//    init(x: Int, y: Int, z: Int) {
//        self.init()
//        self.x = x
//        self.y = y
//        self.z = z
//    }
}
