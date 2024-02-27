import Foundation

public typealias SimpleIndexedStore<Key: Hashable, Value> = IndexedStore<Void, Key, Value>

extension IndexedStore where Environment == Void {
	public init(
		load: @escaping (Key) async throws -> Value,
		save: @escaping (Key, Value) async throws -> Value,
		remove: @escaping (Key) async throws -> Void
	) {
		self.init { key, _ in
			try await load(key)
		} save: { key, value, _ in
			try await save(key, value)
		} remove: { key, _ in
			try await remove(key)
		}
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

extension IndexedStore {
	public func provide(
		_ environment: Environment
	) -> IndexedStore<Void, Key, Value> {
		.init(
			load: { key, _ in
				try await self.load(key, environment)
			},
			save: { key, value, _ in
				try await self.save(key, value, environment)
			},
			remove: { key, _ in
				try await self.remove(key, environment)
			}
		)
	}
}

extension IndexedStore {
	public func pullback<NewEnvironment>(
		_ transform: @escaping (NewEnvironment) -> Environment
	) -> IndexedStore<NewEnvironment, Key, Value> {
		.init { key, newEnvironment in
			try await self.load(key, transform(newEnvironment))
		} save: { key, value, newEnvironment in
			try await self.save(key, value, transform(newEnvironment))
		} remove: { key, newEnvironment in
			try await self.remove(key, transform(newEnvironment))
		}
	}
}

extension IndexedStore where Environment == Void {
	public func require<NewEnvironment>(
		_ type: NewEnvironment.Type
	) -> IndexedStore<NewEnvironment, Key, Value> {
		self.pullback { _ in }
	}
}
