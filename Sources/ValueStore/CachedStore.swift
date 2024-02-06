//
//  CachedStore.swift
//
//
//  Created by Rubén García on 5/2/24.
//

import Foundation

public struct CachedStore<Environment, Value> {
    private let valueStore: ValueStore<Environment, Value>
    private let loadRemote: (Environment) async throws -> Value
    
    public init(
        valueStore: ValueStore<Environment, Value>,
        loadRemote: @escaping (Environment) async throws -> Value
    ) {
        self.loadRemote = loadRemote
        self.valueStore = valueStore
    }
}

extension CachedStore {
    public var update: (Environment) async throws -> Value {
        { environment in
            let value = try await self.loadRemote(environment)
            return try await self.valueStore.save(value, environment)
        }
    }

    public var load: (Environment) async throws -> Value {
        { environment in
            do {
                return try await self.valueStore.load(environment)
            } catch {
                return try await self.update(environment)
            }
        }
    }
    
    public var remove: (Environment) async throws -> Void {
        self.valueStore.remove
    }
}





