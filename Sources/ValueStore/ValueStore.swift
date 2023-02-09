import Foundation

public enum ValueStoreError: Error {
	case noData
	case encoding(Error)
}

public struct ValueStore<Environment, Value> {
	public var load: (Environment) async throws -> Value
	public var save: (Value, Environment) async throws -> Value
	public var remove: (Environment) async throws -> Void
	
	public init(
		load: @escaping (Environment) async throws -> Value,
		save: @escaping (Value, Environment) async throws -> Value,
		remove: @escaping (Environment) async throws -> Void
	) {
		self.load = load
		self.save = save
		self.remove = remove
	}
}

extension ValueStore where Environment == Void {
	public init(
		load: @escaping () async throws -> Value,
		save: @escaping (Value) async throws -> Value,
		remove: @escaping () async throws -> Void
	) {
		self.init { _ in
			try await load()
		} save: { value, _ in
			try await save(value)
		} remove: { _ in
			try await remove()
		}

	}
}

extension ValueStore {
	@inlinable public func process<NewValue>(
		preprocess: @escaping (NewValue) async throws -> Value,
		postprocess: @escaping (Value) async throws -> NewValue
	) -> ValueStore<Environment, NewValue> {
		.init { environment in
			let loaded = try await self.load(environment)
			return try await postprocess(loaded)
		} save: { newValue, environment in
			let preprocessed = try await preprocess(newValue)
			let saved = try await self.save(preprocessed, environment)
			return try await postprocess(saved)
		} remove: { environment in
			try await self.remove(environment)
		}
	}
}

extension ValueStore {
	@inlinable
	public func coded<NewValue>(
		_ codec: Codec<NewValue, Value>
	) -> ValueStore<Environment, NewValue> {
		self.process { newValue in
			try codec.to(newValue)
		} postprocess: { value in
			try codec.from(value)
		}
	}
}
