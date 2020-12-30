//
//  Errors.swift
//  RealmBootcamp
//
//  Created by Dominic Frei on 29/12/2020.
//

enum RealmError: Error {
    case ClassNotFound
    case ObjectNotFound
    case InvalidObject
    case FetchValuesFailed
    case BeginWriteFailed
    case CommitFailed
    case PrimaryKeyViolation
    case SchemaChange
    case InvalidPath
}
