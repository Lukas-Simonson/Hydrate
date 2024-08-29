//
//  Provider.swift
//  
//
//  Created by Lukas Simonson on 8/28/24.
//

/// A protocol that defines how dependencies are created and provided in the Dependency Injection system.
///
/// The `Provider` protocol is a fundamental building block in the Dependency Injection framework.
/// It describes how a dependency is created or retrieved, typically using a `Resolver` to fulfill
/// the required dependencies.
///
public protocol Provider {
    /// The type of the dependency that this provider supplies.
    associatedtype Value

    /// Creates or retrieves an instance of the dependency.
    ///
    /// - Parameter resolver: A `Resolver` used to resolve any dependencies needed to create the `Value`.
    /// - Returns: An instance of the `Value` type.
    ///
    /// - Note: This method may involve complex logic, including resolving multiple dependencies, to produce the required value.
    ///
    mutating func provide(with resolver: Resolver) -> Value
}
