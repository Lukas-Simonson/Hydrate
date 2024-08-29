//
//  Factory.swift
//  
//
//  Created by Lukas Simonson on 8/28/24.
//

import Foundation

/// A `Provider` implementation that generates dependencies using a factory closure.
///
/// The `Factory` struct is an internal component of Hydrate. It allows for the creation of dependencies by invoking a
/// closure that takes a `Resolver` as input. This approach provides flexibility in how dependencies are constructed,
/// making it possible to customize the instantiation process based on the resolver's state or other conditions.
///
internal struct Factory<Value>: Provider {
    
    /// A closure that takes a `Resolver` as input and returns the desired `Value`.
    let factory: (Resolver) -> Value
    
    func provide(with resolver: any Resolver) -> Value {
        return factory(resolver)
    }
}
