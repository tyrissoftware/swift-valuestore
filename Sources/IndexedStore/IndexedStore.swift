import Foundation

public struct IndexedStore<Environment, Key: Hashable, Value> {
	public var load: (Key, Environment) async throws -> Value
	public var save: (Key, Value, Environment) async throws -> Value
	public var remove: (Key, Environment) async throws -> Void

	public init(
		load: @escaping (Key, Environment) async throws -> Value,
		save: @escaping (Key, Value, Environment) async throws -> Value,
		remove: @escaping (Key, Environment) async throws -> Void
	) {
		self.load = load
		self.save = save
		self.remove = remove
	}
}

extension IndexedStore {
	@inlinable public func process<NewValue>(
		preprocess: @escaping (NewValue) async throws -> Value,
		postprocess: @escaping (Value) async throws -> NewValue
	) -> IndexedStore<Environment, Key, NewValue> {
		.init { key, environment in
			let loaded = try await self.load(key, environment)
			return try await postprocess(loaded)
		} save: { key, newValue, environment in
			let preprocessed = try await preprocess(newValue)
			let saved = try await self.save(key, preprocessed, environment)
			return try await postprocess(saved)
		} remove: { key, environment in
			try await self.remove(key, environment)
		}
	}
}
