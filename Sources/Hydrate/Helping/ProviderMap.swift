//
//  ProviderMap.swift
//  
//
//  Created by Lukas Simonson on 8/28/24.
//

import Foundation

/// A thread-safe dictionary wrapper for storing `Provider` instances.
///
/// The `ProviderMap` class serves as the backbone of the Dependency Injection container,
/// managing the storage and retrieval of `Provider` instances in a thread-safe manner.
/// It ensures that dependencies can be resolved efficiently and safely across multiple threads.
///
internal class ProviderMap {
    
    /// The underlying dictionary that stores `Provider` instances, keyed by `ProviderKey`.
    ///
    /// This dictionary maps a combination of a dependency type and an optional name
    /// to a corresponding `Provider`. It is the core data structure that `ProviderMap` uses to manage
    /// the storage and retrieval of dependencies.
    ///
    /// - Note: Access to this dictionary is managed through a thread-safe read-write lock to ensure
    /// that concurrent reads and writes do not lead to race conditions or inconsistent state.
    ///
    private var backing = [ProviderKey: any Provider]()
    
    /// A read-write lock that ensures thread-safe access to the `backing` dictionary.
    ///
    /// The `lock` is used to synchronize access to the `backing` dictionary, preventing data races
    /// when multiple threads attempt to read from or write to the dictionary simultaneously.
    /// The lock allows multiple concurrent reads but enforces exclusive access for writes.
    ///
    private let lock = ReadWriteLock()
    
    /// Accesses the `Provider` associated with the given type and optional name in a thread-safe manner.
    ///
    /// This subscript allows you to retrieve or store a `Provider` in the `ProviderMap` based on
    /// the type of dependency and an optional name. It ensures thread-safe access by using a read-write lock:
    /// - The `get` operation is protected by a read lock, allowing concurrent read access to the underlying dictionary.
    /// - The `set` operation is protected by a write lock, ensuring that only one thread can modify the dictionary at a time.
    ///
    /// - Parameters:
    ///   - name: An optional name to differentiate between multiple instances of the same type.
    ///   - type: The type of the dependency to retrieve or set.
    /// - Returns: The `Provider` associated with the specified type and name, or `nil` if no such `Provider` exists.
    ///
    /// - Note: The use of locks ensures that the `ProviderMap` can safely handle concurrent access in a multithreaded environment.
    ///
    subscript<Value>(name: String?, type: Value.Type) -> (any Provider)? {
        get { lock.read { self.backing[ProviderKey(name: name, type: type)] } }
        set { lock.write { self.backing[ProviderKey(name: name, type: type)] = newValue } }
    }

    /// A unique key used to identify `Provider` instances within the `ProviderMap`.
    ///
    /// The `ProviderKey` structure combines a dependency's type with an optional name to create a unique
    /// identifier for each `Provider` stored in the `ProviderMap`. This key is used internally to map
    /// dependencies to their corresponding `Provider` instances, allowing for precise retrieval and management
    /// of dependencies within the container.
    ///
    private struct ProviderKey: Hashable {
        
        /// The optional name associated with the `Provider`.
        ///
        /// This property allows differentiation between multiple instances of the same type. If `nil`,
        /// the `ProviderKey` represents a non-named instance of the type.
        ///
        let name: String?
        
        /// The `ObjectIdentifier` representing the type of the `Provider`.
        ///
        /// This property uniquely identifies the type of the dependency. It is used in combination with `name`
        /// to form the unique key for the `Provider`.
        ///
        let type: ObjectIdentifier
        
        init<Value>(name: String?, type: Value.Type) {
            self.name = name
            self.type = ObjectIdentifier(type)
        }
    }
}
