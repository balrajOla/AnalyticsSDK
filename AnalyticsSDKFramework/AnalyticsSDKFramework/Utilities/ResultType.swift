//
//  ResultType.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 11/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public enum ResultT<Success, Failure: Error> {
    /// A success, storing a `Success` value.
    case success(Success)
    
    /// A failure, storing a `Failure` value.
    case failure(Failure)
    
    /// Returns a new ResultT, mapping any success value using the given
    /// transformation.
    ///
    /// Use this method when you need to transform the value of a `ResultT`
    /// instance when it represents a success. The following example transforms
    /// the integer success value of a ResultT into a string:
    ///
    ///     func getNextInteger() -> ResultT<Int, Error> { /* ... */ }
    ///
    ///     let integerResultT = getNextInteger()
    ///     // integerResultT == .success(5)
    ///     let stringResultT = integerResultT.map({ String($0) })
    ///     // stringResultT == .success("5")
    ///
    /// - Parameter transform: A closure that takes the success value of this
    ///   instance.
    /// - Returns: A `ResultT` instance with the ResultT of evaluating `transform`
    ///   as the new success value if this instance represents a success.
    public func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
        ) -> ResultT<NewSuccess, Failure> {
        switch self {
        case let .success(success):
            return .success(transform(success))
        case let .failure(failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new ResultT, mapping any failure value using the given
    /// transformation.
    ///
    /// Use this method when you need to transform the value of a `ResultT`
    /// instance when it represents a failure. The following example transforms
    /// the error value of a ResultT by wrapping it in a custom `Error` type:
    ///
    ///     struct DatedError: Error {
    ///         var error: Error
    ///         var date: Date
    ///
    ///         init(_ error: Error) {
    ///             self.error = error
    ///             self.date = Date()
    ///         }
    ///     }
    ///
    ///     let ResultT: ResultT<Int, Error> = // ...
    ///     // ResultT == .failure(<error value>)
    ///     let ResultTWithDatedError = ResultT.mapError({ e in DatedError(e) })
    ///     // ResultT == .failure(DatedError(error: <error value>, date: <date>))
    ///
    /// - Parameter transform: A closure that takes the failure value of the
    ///   instance.
    /// - Returns: A `ResultT` instance with the ResultT of evaluating `transform`
    ///   as the new failure value if this instance represents a failure.
    public func mapError<NewFailure>(
        _ transform: (Failure) -> NewFailure
        ) -> ResultT<Success, NewFailure> {
        switch self {
        case let .success(success):
            return .success(success)
        case let .failure(failure):
            return .failure(transform(failure))
        }
    }
    
    /// Returns a new ResultT, mapping any success value using the given
    /// transformation and unwrapping the produced ResultT.
    ///
    /// - Parameter transform: A closure that takes the success value of the
    ///   instance.
    /// - Returns: A `ResultT` instance with the ResultT of evaluating `transform`
    ///   as the new failure value if this instance represents a failure.
    public func flatMap<NewSuccess>(
        _ transform: (Success) -> ResultT<NewSuccess, Failure>
        ) -> ResultT<NewSuccess, Failure> {
        switch self {
        case let .success(success):
            return transform(success)
        case let .failure(failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new ResultT, mapping any failure value using the given
    /// transformation and unwrapping the produced ResultT.
    ///
    /// - Parameter transform: A closure that takes the failure value of the
    ///   instance.
    /// - Returns: A `ResultT` instance, either from the closure or the previous
    ///   `.success`.
    public func flatMapError<NewFailure>(
        _ transform: (Failure) -> ResultT<Success, NewFailure>
        ) -> ResultT<Success, NewFailure> {
        switch self {
        case let .success(success):
            return .success(success)
        case let .failure(failure):
            return transform(failure)
        }
    }
    
    /// Returns the success value as a throwing expression.
    ///
    /// Use this method to retrieve the value of this ResultT if it represents a
    /// success, or to catch the value if it represents a failure.
    ///
    ///     let integerResultT: ResultT<Int, Error> = .success(5)
    ///     do {
    ///         let value = try integerResultT.get()
    ///         print("The value is \(value).")
    ///     } catch error {
    ///         print("Error retrieving the value: \(error)")
    ///     }
    ///     // Prints "The value is 5."
    ///
    /// - Returns: The success value, if the instance represents a success.
    /// - Throws: The failure value, if the instance represents a failure.
    public func get() throws -> Success {
        switch self {
        case let .success(success):
            return success
        case let .failure(failure):
            throw failure
        }
    }
}

extension ResultT where Failure == Swift.Error {
    /// Creates a new ResultT by evaluating a throwing closure, capturing the
    /// returned value as a success, or any thrown error as a failure.
    ///
    /// - Parameter body: A throwing closure to evaluate.
    @_transparent
    public init(catching body: () throws -> Success) {
        do {
            self = .success(try body())
        } catch {
            self = .failure(error)
        }
    }
}

extension ResultT: Equatable where Success: Equatable, Failure: Equatable { }

extension ResultT: Hashable where Success: Hashable, Failure: Hashable { }
