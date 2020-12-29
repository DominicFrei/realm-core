//
//  PropertyWrapper.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 29/12/2020.
//

@propertyWrapper struct RealmProperty {
    var wrappedValue: Any {
        get {
            return wrappedValue
            // Fetch value from database.
        }
        set {
            // Persist value to database.
        }
    }
    
    init(wrappedValue: Any) {
        self.wrappedValue = wrappedValue
    }
}
