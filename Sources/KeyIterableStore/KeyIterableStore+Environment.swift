import Foundation

public typealias SimpleKeyIterableStore<Key: Hashable, Value> = KeyIterableStore<Void, Key, Value>

extension KeyIterableStore where Environment == Void {
	public init(
		load: @escaping (Key) async throws -> Value,
		save: @escaping (Key, Value) async throws -> Value,
		remove: @escaping (Key) async throws -> Void,
		allKeys: @escaping () -> [Key]
	) {
		self.init(
			indexed: .init { key, _ in
				try await load(key)
			} save: { key, value, _ in
				try await save(key, value)
			} remove: { key, _ in
				try await remove(key)
			},
			allKeys: allKeys
		)
	}

	public func load(_ key: Key) async throws -> Value {
		try await self.load(key, ())
	}
	
	public func save(
		_ key: Key,
		_ value: Value
	) async throws -> Value {
		try await self.save(key, value, ())
	}
	
	public func remove(
		_ key: Key
	) async throws -> Void {
		try await self.remove(key, ())
	}
}

extension KeyIterableStore {
	public func provide(
		_ environment: Environment
	) -> KeyIterableStore<Void, Key, Value> {
		.init(
			indexed: self.indexed.provide(environment),
			allKeys: self.allKeys
		)
	}
}

extension KeyIterableStore {
	public func pullback<NewEnvironment>(
		_ transform: @escaping (NewEnvironment) -> Environment
	) -> KeyIterableStore<NewEnvironment, Key, Value> {
		.init(
			indexed: self.indexed.pullback(transform),
			allKeys: self.allKeys
		)
	}
}

extension KeyIterableStore where Environment == Void {
	public func require<NewEnvironment>(
		_ type: NewEnvironment.Type
	) -> KeyIterableStore<NewEnvironment, Key, Value> {
		.init(
			indexed: self.indexed.require(type),
			allKeys: self.allKeys
		)
	}
}
