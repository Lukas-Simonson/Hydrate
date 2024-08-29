//
//  Singleton.swift
//  
//
//  Created by Lukas Simonson on 8/28/24.
//

import Foundation

/// A `Provider` implementation that directly provides a single, pre-existing instance of a dependency.
///
/// The `SingletonValue` struct is an internal component of Hydrate. It is used to directly return a single, pre-existing 
/// instance of a dependency without generating it through a factory or other means. This makes it ideal
/// for cases where the instance is already known and should be reused throughout the application.
///
internal struct SingletonValue<Value>: Provider {
    
    /// The pre-existing instance of the dependency that this provider will return.
    var value: Value
    
    func provide(with resolver: any Resolver) -> Value {
        return value
    }
}

/// A `Provider` implementation that generates and caches a single instance of a dependency.
///
/// The `SingletonFactory` struct is an internal component of Hydrate. It ensures that a single instance of a dependency 
/// is created and reused throughout the application's lifecycle. This is achieved by caching the generated instance
/// and returning it for all subsequent requests.
///
internal struct SingletonFactory<Value>: Provider {
    
    /// An optional cached instance of the dependency. If `nil`, the dependency has not yet been created.
    var value: Value? = nil
    
    /// A closure that takes a `Resolver` as input and returns the desired `Value`.
    let factory: (Resolver) -> Value
    
    init(value: Value? = nil, factory: @escaping (Resolver) -> Value) {
        self.value = value
        self.factory = factory
    }
    
    mutating func provide(with resolver: any Resolver) -> Value {
        if let value { return value }
        value = factory(resolver)
        return value!
    }
}
