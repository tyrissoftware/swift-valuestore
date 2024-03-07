import Foundation

import IndexedStore

public struct KeyIterableStore<Environment, Key: Hashable, Value> {
	public var indexed: IndexedStore<Environment, Key, Value>
	public var allKeys: () -> [Key]
	
	public init(
		indexed: IndexedStore<Environment, Key, Value>,
		allKeys: @escaping () -> [Key]
	) {
		self.indexed = indexed
		self.allKeys = allKeys
	}
	
	public init(
		load: @escaping (Key, Environment) async throws -> Value,
		save: @escaping (Key, Value, Environment) async throws -> Value,
		remove: @escaping (Key, Environment) async throws -> Void,
		allKeys: @escaping () -> [Key]
	) {
		self.init(
			indexed: .init(
				load: load,
				save: save,
				remove: remove
			),
			allKeys: allKeys
		)
	}
}

// Allow direct access to the IndexedStore functions
extension KeyIterableStore {
	public func load(
		_ key: Key,
		_ environment: Environment
	) async throws -> Value {
		try await self.indexed.load(key, environment)
	}
	
	public func save(
		_ key: Key,
		_ value: Value,
		_ environment: Environment
	) async throws -> Value {
		try await self.indexed.save(key, value, environment)
	}
	
	public func remove(
		_ key: Key, 
		_ environment: Environment
	) async throws -> Void {
		try await self.indexed.remove(key, environment)
	}
}

extension KeyIterableStore {
	@inlinable public func process<NewValue>(
		preprocess: @escaping (NewValue) async throws -> Value,
		postprocess: @escaping (Value) async throws -> NewValue
	) -> KeyIterableStore<Environment, Key, NewValue> {
		.init(
			indexed: self.indexed.process(preprocess: preprocess, postprocess: postprocess),
			allKeys: self.allKeys
		)
	}
}
