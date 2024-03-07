import Foundation

extension IndexedStore {
	public func copy(
		_ key: Key,
		to target: IndexedStore<Environment, Key, Value>,
		environment: Environment
	) async throws -> Value {
		let result = try await self.load(key, environment)
		return try await target.save(key, result, environment)
	}
	
	public func move(
		_ key: Key,
		to target: IndexedStore<Environment, Key, Value>,
		environment: Environment
	) async throws -> Value {
		let result = try await self.copy(
			key,
			to: target,
			environment: environment
		)
		
		try await self.remove(key, environment)
		
		return result
	}
}

extension IndexedStore where Environment == Void {
	public func copy(
		_ key: Key,
		to target: IndexedStore<Void, Key, Value>
	) async throws -> Value {
		try await self.copy(
			key,
			to: target,
			environment: ()
		)
	}
	
	public func move(
		_ key: Key,
		to target: IndexedStore<Void, Key, Value>
	) async throws -> Value {
		try await self.move(
			key,
			to: target,
			environment: ()
		)
	}
}

extension IndexedStore {
	public func cached(
		by cache: Self
	) -> Self {
		.init { key, environment in
			guard let cached = try? await cache.load(key, environment) else {
				let value = try await self.load(key, environment)
				_ = try? await cache.save(key, value, environment)
				return value
			}
			
			return cached
			
		} save: { key, value, environment in
			_ = try await cache.save(key, value, environment)
			return try await self.save(key, value, environment)
		} remove: { key, environment in
			try await cache.remove(key, environment)
			try await self.remove(key, environment)
		}
	}
}

