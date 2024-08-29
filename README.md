<div align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://github.com/Lukas-Simonson/Hydrate/blob/main/hydrateLogoDark.png?raw=true">
        <source media="(prefers-color-scheme: light)" srcset="https://github.com/Lukas-Simonson/Hydrate/blob/main/hydrateLogoLight.png?raw=true">
        <img alt="Hydrate: a Dependency Injection Framework for Swift" src="https://raw.githubusercontent.com/groue/GRDB.swift/master/GRDB.png" width=200>
    </picture>
</div>

<p align="center">
    <strong>A Swift Dependency Injection Framework Made Simple</strong><br>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/"><img alt="Swift 5.10" src="https://img.shields.io/badge/swift-5.10-orange.svg?style=flat"></a>
    <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-black.svg"></a>
</p>

## Overview
Hydrate is a Swift Dependency Injection (DI) framework designed with ease of use, and simplicity as its goal. Leveraging the power of DI, Hydrate allows you to decouple components, making your codebase more modular, testable, and maintainable. Hydrate provides a simple, and beautiful approach to dependency management, supporting a variety of injection patterns, including singleton instances, factory-generated dependencies, and the ability to build your own provider implementations. With thread-safe storage and a clean, intuitive API, Hydrate ensures that your dependencies are resolved efficiently and safely, even in complex, multi-threaded environments.

## Quickstart Guide

### Registering Dependencies
Hydrate makes it simple to register and manage dependencies within your application. There are several methods available for registering dependencies, depending on how you want them to be resolved. Below are examples of how to register dependencies using Hydrate's included API.

#### Registering a Singleton Instance
A singleton instance is a dependency that should only have one shared instance throughout the applications lifecycle. You can easily register a singleton instance using the `registerSingleton` method.

```swift
let service = MovieAPI()
Container.registerSingleton(service)
```

#### Registering a Singleton Factory
Sometimes, you may want to ensure that a dependency is only created once; however, this dependency may rely on other injected dependencies. You can register a singleton factory to control how the initial instance of your singleton is created. The singleton factory uses a closure to build the instance of your Singleton the first time it is created. This closure takes a `Resolver` as a parameter that you can use to resolve other registered dependencies.

```swift
Container.registerSingleton { resolver in
    MovieRepository(api: resolver.resolve(MovieAPI.self)) 
}
```

- Here a factory closure is registered to create an instance of `MovieRepository`. The closure will be called once to create the instance, and that instance will be reused for all subsequent resolutions.

#### Registering a Factory
If you need a fresh instance of a dependency each time it's requested, you can register a factory that creates a new instance every time:

```swift
Container.register { resolver in
    return FetchMovieUseCase(dependency: resolver.resolve(MovieRepository.self))
}
```

- This example registers a factory that produces a new instance of `MyService` each time it is resolved. This is useful for dependencies that should not be shared or cached.

#### Aliasing Types
It is common practice to write Protocols to define the functionality of a dependency, and then rely on that protocol in the rest of your application. This allows you to easily switch between different concrete versions of that protocol. You can easily alias a registered type to match that of a protocol, by using the `type` parameter of all the registration functions.

```swift
protocol MovieDatabase {  }
class CoreDataMovieDatabase: MovieDatabase {  }

Container.registerSingleton(as: MovieDatabase.self) { _ in
    CoreDataMovieDatabase()
}
```

- This example shows how you can register a concrete type as a protocol type.

#### Named Registrations
In Hydrate, you can register multiple instances of the same type by using names. This is useful when you have different configurations or variations of the same dependency.

```swift
Container.registerSingleton(named: "transientRepository") { resolver in
    MovieRepository(api: resolver.resolve(MovieAPI.self))
}

Container.registerSingleton(as: MovieRepository.self, named: "cachedRepository") { resolver in
    // CachedMovieRepository is a child class of MovieRepository, so it can be cast here.
    CachedMovieRepository(api: resolver.resolve(MovieAPI.self), db: resolver.resolve(MovieDatabase.self))
}
```

- This example shows two different versions of the same type being registered, by providing a name you can differentiate between the two versions.

---

### Resolving Dependencies
Once your dependencies are registered, resolving them in Hydrate is very straightforward. The framework provides several ways to access and inject your dependencies, ensuring they are available wherever you need them in your application.

> [!WARNING]
> Attempting to resolve a dependency with no matching provider registered will result in a runtime error.

#### Resolving A Dependency
The most direct way to resolve a dependency is by using the `resolve` method on a `Container`:

```swift
let repository = Container.resolve(MovieRepository.self)
```

- In this example, the `MovieRepository` type is resolved from the shared `Container`. The resolved instance is returned and assigned to the `repository` constant.

#### Resolving a Named Dependency
If you registered a dependency with a specific name, you can resolve it by specifying the name during resolution:

```swift
let transientRepository = Container.resolve(MovieRepository.self, named: "transientRepository")
let cachedRepository = Container.resolve(MovieRepository.self, named: "cachedRepository")
```

- This example demonstrates how to resolve two different instances of `MovieRepository` that were registered using names.

#### Resolving with the `Hydrated` Property Wrapper

To simplify dependency injection, Hydrate provides the `Hydrated` property wrapper. This wrapper automatically resolved and injects dependencies when they are accessed:

```swift
class MovieVM {
    @Hydrated var service: MyService
    
    init() { }
    
    func useService() {
        service.performTask()
    }
}
```

- In this example, the `@Hydrated` property wrapper automatically resolves `MyService` from the shared `Container` when the `service` property is accessed. This makes your code cleaner, and reduces boilerplate!

#### Resolving Named Dependencies When Using The `Hydrated` Property Wrapper.

The `@Hydrated` property wrapper can take a name parameter to allow you to resolve named dependencies.

```swift
class MovieVM {
    @Hydrated(name: "cachedRepository") var repository: MovieRepository
    
    init() { }
    
    func getMovies() {
        repository.getMovies()
    }
}
```

---

### Using Multiple Containers
Hydrate provides a convenient shared `Container` for global dependency management; however, there are scenarios where you may want to seperate your logic into multiple containers. This approach allows you to isolate dependencies for different parts of your application, making it easier to manage configurations, testing, and modular development.

#### Creating a Container
You can create a new `Container` instance whenever you need to manage dependencies separately from the shared container:

```swift
let customContainer = Container()
```

- This example shows how to create a new `Container` instance, which operates independently of the shared container. You can register and resolve dependencies in this container without affecting the shared instance.

#### Registering Dependencies in a Custom Container
When registering dependencies on the shared `Container` Hydrate provides static functions to reduce boilerplate. Each of these functions, however, has an instance function match that can be used on your instance.

```swift
// Using the shared `Container`
Container.registerSingleton {
    MyService()
}

// Using a custom `Container`
customContainer.registerSingleton {
    MyService()
}
```

#### Resolving Dependencies from a Custom Container
Just like with registering dependencies, each of the static `Container` functions that can be used with the shared `Container`, has an instance function match that can be used on your instance.

```swift
// Using the shared `Container`
let service = Container.resolve(MyService.self)

// Using a custom `Container`
let service = customContainer.resolve(MyService.self)
```

#### Resolving Dependencies from a Custom Container Using the `Hydrated` property wrapper.
When using the `@Hydrated` property wrapper, you can optionally provide a `Container` instance for the property wrapper to resolve its dependencies from, if no `Container` is provided, the shared one will be used.

```swift
class MovieVM {
    @Hydrated(container: customContainer) var service: MyService
    
    init() { }
    
    func useService() {
        service.performTask()
    }
}
```

---

### Custom Providers
While Hydrate offers built-in mechanisms for managing dependencies through singleton and factory providers, there may be times when you need more control over how dependencies are created or managed. Custom providers give you this flexibility by allowing you to define your own logic for creating and providing dependencies.

#### Implementing a Custom Provider
To create a custom provider, you need create a type that conforms to the `Provider` protocol. This protocol requires a `provide(with:)` method, which is responsible for generating or retrieving the dependency.

```swift
struct ExpirableSingletonFactory<Value>: Provider {
    
    let duration: TimeInterval
    let factory: (Resolver) -> Value
    
    var expirationDate: Date = .now
    var value: Value? = nil
    
    mutating func provide(with resolver: Resolver) -> Value {
        if let value, expirationDate > .now {
            return value
        }
        
        self.value = factory(resolver)
        self.expirationDate = .now.advanced(by: duration)
        return self.value!
    }
}
```

- This example, `ExpirableSingletonFactory` conforms to the `Provider` protocol and provides a custom implementation for creating an instance of a generic `Value`. It allows the specification of a duration that the singleton should exist before being re-resolved. The `provid(with:)` method can include any logic necessary to configure or retrieve the service, such as resolving additional dependencies.

#### Registering a Custom Provider
Once you've created a custom provider, you can register it with a container using the `registerProvider()` method. You can either use the static method to add it to the shared `Container` or use an instance method on any custom `Containers`

```swift
Container.registerProvider(
    // New Dependency Resolved Every 5 Minutes.
    ExpirableSingletonFactory(duration: 300) { _ in
        ExpirableDependecy()
    }
)
```

#### Resolving When Using A Custom Provider
Nothing changes about the resolution process when using a provider, you can do it all the same way, but your custom provider will be used when resolving the dependency attached to it.

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the Swift compiler.

To add [Hydrate](https://github.com/Lukas-Simonson/Hydrate) to your project do the following.
- Open Xcode
- Click on `File -> Add Packages`
- Use this repositories URL (https://github.com/Lukas-Simonson/Hydrate.git) in the top right of the window to download the package.
- When prompted for a Version or a Branch, we suggest you use the branch: main
