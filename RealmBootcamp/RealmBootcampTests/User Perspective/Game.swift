//
//  Game.swift
//  RealmBootcampTests
//
//  Created by Dominic Frei on 22/12/2020.
//

@testable import RealmBootcamp

struct Game: Persistable {
//    let name: String
    var releaseYear = 2016
    var primaryKey: String {
        return "releaseYear"
    }
}
