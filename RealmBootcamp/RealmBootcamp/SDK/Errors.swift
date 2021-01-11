//
//  Errors.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 29/12/2020.
//

enum RealmError: Error {
    case ClassNotFound
    case PropertiesNotFound
    case ObjectNotFound
    case InvalidObject
    case FetchValuesFailed
    case StartTransaction
    case EndTransaction
    case PrimaryKeyViolation
    case SchemaChange
    case InvalidSchema
    case InvalidPath
    case ObjectCreation
    case UpdateFailed
    case InvalidValueType
}
