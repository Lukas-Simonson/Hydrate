//
//  Container.swift
//  
//
//  Created by Lukas Simonson on 8/28/24.
//

/// The `Container` class is the central component of Hydrate, responsible for managing and resolving dependencies.
///
/// The `Container` class ties together the various elements of the Dependency Injection system, including the storage and management
/// of `Provider` instances via a `ProviderMap`. It provides a global point of access to registered dependencies through the
/// `shared` instance, and can also be instantiated for more granular or scoped dependency management needs.
///
public final class Container {
    
    /// The shared instance of the `Container`.
    ///
    /// This static property provides a globally accessible `Container` instance, often used as the default container throughout an application.
    /// By using the shared container, you can manage dependencies in a centralized manner, making it easy to access and inject them
    /// wherever needed.
    ///
    public static var shared =  Container()
    
    /// The `ProviderMap` instance used to store and manage `Provider` instances.
    ///
    /// This property holds the `ProviderMap` that the `Container` uses to store and retrieve `Provider` instances.
    /// The `ProviderMap` manages the thread-safe storage of providers, allowing the container to efficiently resolve
    /// dependencies when requested.
    ///
    private var providers = ProviderMap()
    
    /// Initializes a new instance of the `Container`.
    ///
    /// This initializer creates a new, empty `Container`. It can be used to create additional containers for specific purposes,
    /// such as testing different configurations or managing dependencies in a modular way.
    ///
    public init() { }
}

// MARK: - Static Access To Singleton Container
extension Container {
    
    /// Registers a `Provider` in the shared `Container` instance for a specific dependency type and optional name.
    ///
    /// This static method provides a convenient way to register a `Provider` directly on the `Container` type,
    /// using the shared container instance. It makes it easier to manage dependencies globally across the application.
    ///
    /// - Parameters:
    ///   - provider: The `Provider` instance that will supply the dependency. This provider should conform to the `Provider` protocol and be capable of creating or retrieving the specified dependency type.
    ///   - name: An optional string used to differentiate between multiple providers of the same type. Defaults to `nil`.
    ///
    public static func registerProvider<P: Provider>(_ provider: P, named name: String? = nil) {
        Self.shared.registerProvider(provider, named: name)
    }
    
    /// Registers a factory in the shared `Container` instance to create a dependency instance each time it is requested.
    ///
    /// This static method allows you to register a factory closure directly on the `Container` type,
    /// using the shared container instance. The factory generates a new instance of the dependency each time it is requested.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency being registered. Defaults to the inferred type from the factory.
    ///   - name: An optional string used to differentiate between multiple instances of the same type. Defaults to `nil`.
    ///   - factory: A closure that takes a `Resolver` as input and returns the desired dependency instance. This factory is invoked each time the dependency is resolved.
    ///
    public static func register<Value>(type: Value.Type = Value.self, named name: String? = nil, factory: @escaping (Resolver) -> Value) {
        Self.shared.register(type: type, named: name, factory: factory)
    }
    
    /// Registers a pre-existing singleton instance in the shared `Container` instance.
    ///
    /// This static method allows you to register a pre-existing instance of a dependency as a singleton directly on the `Container` type,
    /// using the shared container instance. The instance is stored and returned as-is whenever the dependency is requested.
    ///
    /// - Parameters:
    ///   - value: The pre-existing instance of the dependency to be registered as a singleton.
    ///   - name: An optional string used to differentiate between multiple instances of the same type. Defaults to `nil`.
    ///   - type: The type of the dependency being registered. Defaults to the inferred type of the `value`.
    ///
    public static func registerSingleton<Value>(_ value: Value, named name: String? = nil, as type: Value.Type = Value.self) {
        Self.shared.registerSingleton(value, named: name)
    }
    
    /// Registers a singleton factory in the shared `Container` instance to create and cache a dependency instance.
    ///
    /// This static method allows you to register a factory closure that generates a singleton instance of a dependency directly on the `Container` type,
    /// using the shared container instance. The generated instance is cached and returned for all subsequent requests.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency being registered. Defaults to the inferred type from the factory.
    ///   - name: An optional string used to differentiate between multiple instances of the same type. Defaults to `nil`.
    ///   - factory: A closure that takes a `Resolver` as input and returns the desired dependency instance. This factory is invoked only once, and the result is cached.
    ///   
    public static func registerSingleton<Value>(as type: Value.Type = Value.self, named name: String? = nil, factory: @escaping (Resolver) -> Value) {
        Self.shared.registerSingleton(as: type, named: name, factory: factory)
    }
    
    /// Resolves and returns an instance of the specified type from the shared `Container` instance.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency to be resolved.
    ///   - name: An optional string to differentiate between multiple instances of the same type.
    /// - Returns: An instance of the specified type `Value`.
    ///
    /// - Note: If the dependency cannot be resolved, this method will fatally error.
    ///
    public static func resolve<Value>(_ type: Value.Type, named name: String?) -> Value {
        Self.shared.resolve(type, named: name)
    }
}

// MARK: - Resolver Conformance
extension Container: Resolver {
    public func resolve<Value>(_ type: Value.Type, named name: String?) -> Value {
        guard let value = providers[name, Value.self]?.provide(with: self) as? Value
        else { fatalError("Missing or Invalid provider for \(type)") }
        return value
    }
}

// MARK: - Provider Registration
extension Container {
    
    /// Registers a `Provider` in the `Container` for a specified dependency type and optional name.
    ///
    /// This method allows you to register a `Provider` instance within the `Container`, making it responsible for supplying
    /// a specific type of dependency. Optionally, you can provide a name to differentiate between multiple providers of the same type.
    ///
    /// - Parameters:
    ///   - provider: The `Provider` instance that will supply the dependency. This provider should conform to the `Provider` protocol and be capable of creating or retrieving the specified dependency type.
    ///   - name: An optional string used to differentiate between multiple providers of the same type. If `nil`, the provider is registered as the default provider for that type.
    ///
    /// - Note: Once registered, the `Provider` can be used by the `Container` to resolve dependencies of the specified type.
    ///   If a name is provided, the `Provider` is registered under that name, allowing for more granular control over
    ///   which `Provider` is used during dependency resolution.
    ///
    public func registerProvider<P: Provider>(_ provider: P, named name: String? = nil) {
        providers[name, P.Value.self] = provider
    }
}

// MARK: - Singleton Registration
extension Container {
    
    /// Registers a pre-existing singleton instance in the `Container`.
    ///
    /// This method allows you to register a pre-existing instance of a dependency as a singleton in the `Container`.
    /// The instance is stored and returned as-is whenever the dependency is requested, ensuring that the same instance is reused throughout the application.
    ///
    /// - Parameters:
    ///   - value: The pre-existing instance of the dependency to be registered as a singleton.
    ///   - name: An optional string used to differentiate between multiple instances of the same type. Defaults to `nil`.
    ///   - type: The type of the dependency being registered. Defaults to the inferred type of the `value`.
    ///
    public func registerSingleton<Value>(_ value: Value, named name: String? = nil, as type: Value.Type = Value.self) {
        providers[name, Value.self] = SingletonValue(value: value)
    }
    
    /// Registers a singleton factory in the `Container` to create and cache a dependency instance.
    ///
    /// This method allows you to register a factory closure that will generate a singleton instance of a dependency the first time it is requested.
    /// The generated instance is then cached and returned for all subsequent requests, ensuring that the same instance is reused.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency being registered. Defaults to the inferred type from the factory.
    ///   - name: An optional string used to differentiate between multiple instances of the same type. Defaults to `nil`.
    ///   - factory: A closure that takes a `Resolver` as input and returns the desired dependency instance. This factory is invoked only once, and the result is cached.
    ///
    public func registerSingleton<Value>(as type: Value.Type = Value.self, named name: String? = nil, factory: @escaping (Resolver) -> Value) {
        providers[name, Value.self] = SingletonFactory(factory: factory)
    }
}

// MARK: - Factory Registration
extension Container {
    
    /// Registers a factory in the `Container` to create a dependency instance each time it is requested.
    ///
    /// This method allows you to register a factory closure that will generate a new instance of a dependency each time it is requested.
    /// Unlike a singleton, this factory does not cache the instance, ensuring that a fresh instance is created on every request.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency being registered. Defaults to the inferred type from the factory.
    ///   - name: An optional string used to differentiate between multiple instances of the same type. Defaults to `nil`.
    ///   - factory: A closure that takes a `Resolver` as input and returns the desired dependency instance. This factory is invoked each time the dependency is resolved.
    ///
    public func register<Value>(type: Value.Type = Value.self, named name: String? = nil, factory: @escaping (Resolver) -> Value) {
        providers[name, Value.self] = Factory(factory: factory)
    }
}
