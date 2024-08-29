//
//  Resolver.swift
//
//
//  Created by Lukas Simonson on 8/28/24.
//

/// A protocol that defines the functionality to resolve injected dependencies.
///
/// The `Resolver` protocol provides a generic method to resolve instances of a specified type.
/// This is a fundamental component of the Dependency Injection system, enabling the retrieval of dependencies
/// that have been registered in a dependency container.
///
public protocol Resolver {
    
    /// Resolves and returns an instance of the specified type.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency to be resolved.
    ///   - name: An optional string to differentiate between multiple instances of the same type.
    /// - Returns: An instance of the specified type `Value`.
    ///
    /// - Note: If the dependency cannot be resolved, this method should fatally error.
    func resolve<Value>(_ type: Value.Type, named name: String?) -> Value
}


extension Resolver {
    
    /// Resolves and returns an instance of the specified type.
    ///
    /// This method is a convenience overload of the `resolve(_:named:)` method. It allows for resolving dependencies
    /// without needing to specify a name, defaulting to `nil` for the `name` parameter.
    ///
    /// - Parameter type: The type of the dependency to be resolved.
    /// - Returns: An instance of the specified type `Value`.
    ///
    /// - Note: This method internally calls `resolve(_:named:)` with `nil` as the name parameter.
    /// If you have multiple instances of the same type registered with different names, consider using the full
    /// `resolve(_:named:)` method to specify which instance to resolve.
    ///
    public func resolve<Value>(_ type: Value.Type) -> Value {
        self.resolve(type, named: nil)
    }
}
