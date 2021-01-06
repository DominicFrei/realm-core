//
//  Array+Extension.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 30/12/2020.
//

extension Array where Element: Persistable {
    
    func primaryKey(_ primaryKey: Int) throws -> [Element] {
        let filteredArray = try self.filter({ (object) -> Bool in
            try object.primaryKeyValue() == primaryKey
        })
        return filteredArray
    }
    
}
