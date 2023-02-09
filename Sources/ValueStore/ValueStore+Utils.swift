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


public struct Conversion<Input, Output> {
	public var to: (Input) -> Output
	public var from: (Output) -> Input
	
	public init(
		to: @escaping (Input) -> Output,
		from: @escaping (Output) -> Input
	) {
		self.to = to
		self.from = from
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
