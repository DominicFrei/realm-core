//
//  Persistable.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

import RealmC

protocol Persistable: Codable, Equatable {
    var primaryKey: String { get }
    func isValid() -> Bool
}

extension Persistable {
    
    func properties() -> [Property] {
        let mirror = Mirror(reflecting: self)
        let properties = mirror.children.map { Property(label: $0.label!, value: $0.value) }
        return properties
    }
    
    func typeName() -> String {
        return String(describing: Self.self)
    }
    
    func isValid() -> Bool {
        return false
    }
    
    func primaryKeyValue() throws -> Int {
        guard let primaryKeyValue = self.properties().filter({ $0.label == self.primaryKey }).first?.value as? Int else {
            throw RealmError.PrimaryKeyViolation
        }
        return primaryKeyValue
    }    
    
}

func ==<T: Persistable>(lhs: T, rhs: T) -> Bool {
    return lhs.typeName() == rhs.typeName() && lhs.primaryKey == rhs.primaryKey
}
