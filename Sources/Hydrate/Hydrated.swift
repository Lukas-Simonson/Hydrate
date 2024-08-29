//
//  Hydrate.swift
//
//
//  Created by Lukas Simonson on 8/28/24.
//

/// A property wrapper that simplifies and streamlines the injection of dependencies.
///
/// The `Hydrated` property wrapper is designed to make dependency injection clean and easy within your code.
/// It automatically resolves and injects dependencies from a `Container`, with support for caching the resolved value
/// to avoid repeated lookups. This ensures that dependencies are only resolved once, improving performance and reducing
/// unnecessary operations.
///
/// ## Example
/// Here’s an example of using the `Hydrated` property wrapper to inject a dependency:
///
/// ```swift
/// class MyViewModel {
///     @Hydrated var repository: RepositoryService
///
///     func performAction() {
///         repository.performAction()
///     }
/// }
/// ```
///
/// In this example, `MyService` is automatically resolved from the container and injected into the `service` property
/// of `MyViewModel`. The first access to `service` triggers the resolution process, and subsequent accesses return the cached value.
///
@propertyWrapper
public struct Hydrated<Value> {
    
    /// The container from which the dependency is resolved.
    ///
    /// This property holds a reference to the `Container` instance that is used to resolve the dependency.
    /// By default, it points to the shared container (`.shared`), but it can be customized during initialization
    /// to use a different container if needed. This allows for flexibility in managing different sets of dependencies
    /// across different parts of the application.
    ///
    private let container: Container
    
    /// The optional name associated with the dependency.
    ///
    /// This property stores an optional name used to differentiate between multiple instances of the same type within the container.
    /// If a name is provided, it ensures that the correct instance of the dependency is resolved.
    /// If `nil`, the default instance of the type is resolved. This feature is useful when the container holds multiple configurations
    /// or variations of the same dependency type.
    ///
    private let name: String?
    
    /// The cache used to store the resolved dependency.
    ///
    /// This property is an instance of the `Cache` class, responsible for storing the resolved dependency once it has been retrieved from the container.
    /// By caching the value, the property wrapper ensures that the dependency is only resolved once, and subsequent accesses return the cached value.
    /// This improves performance and reduces the overhead of repeatedly resolving the same dependency.
    ///
    private let cache = Cache()
    
    /// Initializes a new `Hydrated` property wrapper with an optional container and name.
    ///
    /// - Parameters:
    ///   - container: The `Container` instance from which the dependency should be resolved. Defaults to `.shared`.
    ///   - name: An optional name to differentiate between multiple instances of the same type.
    /// - Returns: A new `Hydrated` property wrapper ready to resolve and inject the specified dependency.
    ///
    public init(container: Container = .shared, name: String? = nil) {
        self.container = container
        self.name = name
    }
    
    /// The resolved value of the dependency.
    ///
    /// The `wrappedValue` property provides access to the resolved dependency. On first access, it resolves the dependency
    /// from the container and caches it for future use. If the value has already been cached, the cached value is returned
    /// immediately, avoiding a repeated resolution process.
    ///
    public var wrappedValue: Value {
        if let value = cache.value { return value }
        cache.value = container.resolve(Value.self, named: name)
        return cache.value!
    }

    /// A private class used to cache the resolved dependency within the `Hydrated` property wrapper.
    ///
    /// The `Cache` class is responsible for storing the resolved value of a dependency after it has been retrieved from the container.
    /// This caching mechanism ensures that the dependency is only resolved once, and the cached value is returned on subsequent accesses,
    /// improving performance by eliminating the need for repeated resolutions.
    ///
    private class Cache {
        
        /// The cached value of the resolved dependency.
        ///
        /// This property stores the resolved value of the dependency. It is initially `nil` and is set to the resolved value
        /// the first time the dependency is accessed through the `Hydrated` property wrapper. Once set, it retains the value
        /// for future accesses, ensuring that the same instance is reused.
        ///
        var value: Value?
    }
}
