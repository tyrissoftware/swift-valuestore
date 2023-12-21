import Foundation

public struct CachedStore<Environment, Value> {
	public var loadRemote: () async throws -> Value
	public var valueStore: ValueStore<Environment, Value>
	
	public init(
		loadRemote: @escaping () async throws -> Value,
		valueStore: ValueStore<Environment, Value>
	) {
		self.loadRemote = loadRemote
		self.valueStore = valueStore
	}
}

extension CachedStore {
	public func update(_ environment: Environment) async throws -> Value {
		let remote = try await self.loadRemote()
		return try await self.valueStore.save(remote, environment)
	}
	
	public func load(_ environment: Environment) async throws -> Value {
		let local = try? await self.valueStore.load(environment)
		
		guard let local else {
			return try await self.update(environment)
		}
		
		return local
	}
	
	public func updateWithPrevious(_ environment: Environment) async throws -> (previous: Value?, current: Value) {
		let local = try? await self.valueStore.load(environment)
			
		let remote = try await update(environment)
			
		return (previous: local, current: remote)
	}
	
	public func remove(_ environment: Environment) async throws {
		try await self.valueStore.remove(environment)
	}
}

extension CachedStore where Environment == Void {
	public func update() async throws -> Value {
		try await self.update(())
	}
	
	public func load() async throws -> Value {
		try await self.load(())
	}
	
	public func updateWithPrevious() async throws -> (previous: Value?, current: Value) {
		try await self.updateWithPrevious(())
	}
}

extension CachedStore {
	public static func const(_ value: Value) -> Self {
		.init(
			loadRemote: { value },
			valueStore: .const(value)
		)
	}
	
	public static func error<E: Error>(_ error: E) -> Self {
		.init(
			loadRemote: { throw error },
			valueStore: .error(error)
		)
	}
}
