//
//  Persistable.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 22/12/2020.
//

protocol Persistable: Codable {
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
    
}
