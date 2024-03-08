import Foundation

extension KeyIterableStore {
	public func copy(
		_ key: Key,
		to target: KeyIterableStore<Environment, Key, Value>,
		environment: Environment
	) async throws -> Value {
		let result = try await self.load(key, environment)
		return try await target.save(key, result, environment)
	}
	
	public func move(
		_ key: Key,
		to target: KeyIterableStore<Environment, Key, Value>,
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

extension KeyIterableStore where Environment == Void {
	public func copy(
		_ key: Key,
		to target: KeyIterableStore<Void, Key, Value>
	) async throws -> Value {
		try await self.copy(
			key,
			to: target,
			environment: ()
		)
	}
	
	public func move(
		_ key: Key,
		to target: KeyIterableStore<Void, Key, Value>
	) async throws -> Value {
		try await self.move(
			key,
			to: target,
			environment: ()
		)
	}
}

extension KeyIterableStore {
	public func cached(
		by cache: Self
	) -> Self {
		.init(
			indexed: self.indexed.cached(by: cache.indexed),
			allKeys: self.allKeys
		)
	}
}

