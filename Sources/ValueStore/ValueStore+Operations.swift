import Foundation

extension ValueStore {
	public func copy(
		to target: ValueStore<Environment, Value>,
		environment: Environment
	) async throws -> Value {
		let result = try await self.load(environment)
		return try await target.save(result, environment)
	}
	
	public func move(
		to target: ValueStore<Environment, Value>,
		environment: Environment
	) async throws -> Value {
		let result = try await self.copy(
			to: target,
			environment: environment
		)
		
		try await self.remove(environment)
		
		return result
	}
}

extension ValueStore where Environment == Void {
	public func copy(
		to target: ValueStore<Void, Value>
	) async throws -> Value {
		try await self.copy(
			to: target,
			environment: ()
		)
	}
	
	public func move(
		to target: ValueStore<Void, Value>
	) async throws -> Value {
		try await self.move(
			to: target,
			environment: ()
		)
	}
}

extension ValueStore {
	public func cached(
		by cache: Self
	) -> Self {
		.init { environment in
			guard let cached = try? await cache.load(environment) else {
				let value = try await self.load(environment)
				_ = try? await cache.save(value, environment)
				return value
			}
			
			return cached
			
		} save: { value, environment in
			_ = try await cache.save(value, environment)
			return try await self.save(value, environment)
		} remove: { environment in
			try await cache.remove(environment)
			try await self.remove(environment)
		}
	}
}
