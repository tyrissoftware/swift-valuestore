import Foundation

extension ValueStore where Environment == Void {
	public func load() async throws -> Value {
		try await self.load(())
	}
	
	public func save(
		_ value: Value
	) async throws -> Value {
		try await self.save(value, ())
	}
	
	public func remove() async throws -> Void {
		try await self.remove(())
	}
}

extension ValueStore {
	public func provide(
		_ environment: Environment
	) -> ValueStore<Void, Value> {
		.init(
			load: { _ in
				try await self.load(environment)
			},
			save: { a, _ in
				try await self.save(a, environment)
			},
			remove: { _ in
				try await self.remove(environment)
			}
		)
	}
}

extension ValueStore {
	public func pullback<NewEnvironment>(
		_ transform: @escaping (NewEnvironment) -> Environment
	) -> ValueStore<NewEnvironment, Value> {
		.init { newEnvironment in
			try await self.load(transform(newEnvironment))
		} save: { value, newEnvironment in
			try await self.save(value, transform(newEnvironment))
		} remove: { newEnvironment in
			try await self.remove(transform(newEnvironment))
		}
	}
}

extension ValueStore where Environment == Void {
	public func require<NewEnvironment>(
		_ type: NewEnvironment.Type
	) -> ValueStore<NewEnvironment, Value> {
		self.pullback { _ in }
	}
}
