import Foundation

extension ValueStore {
	public func `default`(
		_ value: Value
	) -> ValueStore<Environment, Value> {
		.init { environment in
			let result = try? await self.load(environment)
			return result ?? value
		} save: { value, environment in
			try await self.save(value, environment)
		} remove: { environment in
			try await self.remove(environment)
		}
	}
	
	public func update(
		environment: Environment,
		_ modify: @escaping (inout Value) -> Void
	) async throws -> Value {
		var value = try await self.load(environment)
		modify(&value)
		return try await self.save(value, environment)
	}
}

extension ValueStore where Environment == Void {
	public func update(
		_ modify: @escaping (inout Value) -> Void
	) async throws -> Value {
		var value = try await self.load(())
		modify(&value)
		return try await self.save(value, ())
	}
}

extension ValueStore {
	public func map<NewValue>(
		_ transformInput: @escaping (NewValue) -> Value,
		_ transformOutput: @escaping (Value) -> NewValue
	) -> ValueStore<Environment, NewValue> {
		.init { environment in
			let loaded = try await self.load(environment)
			return transformOutput(loaded)
		} save: { newValue, environment in
			let saved = try await self.save(transformInput(newValue), environment)
			return transformOutput(saved)
		} remove: { environment in
			try await self.remove(environment)
		}
	}
	
	public func map<NewValue>(
		_ conversion: Conversion<NewValue, Value>
	) -> ValueStore<Environment, NewValue> {
		self.map(conversion.to, conversion.from)
	}
}

extension ValueStore {
	public func mapError<NewError: Error>(
		_ transformError: @escaping (Error) -> NewError
	) -> ValueStore<Environment, Value> {
		.init { environment in
			do {
				return try await self.load(environment)
			}
			catch let error {
				throw(transformError(error))
			}
		} save: { value, environment in
			do {
				return try await self.save(value, environment)
			}
			catch let error {
				throw transformError(error)
			}
		} remove: { environment in
			do {
				try await self.remove(environment)
			}
			catch let error{
				throw transformError(error)
			}
		}
	}
}

extension ValueStore {
	public func load(default value: Value, environment: Environment) async -> Value {
		(try? await self.load(environment)) ?? value
	}
}

extension ValueStore where Environment == Void {
	public func load(default value: Value) async -> Value {
		(try? await self.load(())) ?? value
	}
}


public extension ValueStore where Environment == Void {
	func cached(
		load: @escaping () async throws -> Value
	) async throws -> Value {
		try await self.cached(
			load: load,
			environment: ()
		)
	}
}

public extension ValueStore {
	func cached(
		load: @escaping (Environment) async throws -> Value,
		environment: Environment
	) async throws -> Value {
		let value: Value
		
		do {
			value = try await self.load(environment)
		} catch {
			value = try await load(environment)
		}
		
		return try await self.save(value, environment)
	}
}
