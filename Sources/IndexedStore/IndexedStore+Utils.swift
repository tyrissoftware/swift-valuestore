import Foundation

import ValueStore

extension IndexedStore {
	public func `default`(
		_ value: Value
	) -> IndexedStore<Environment, Key, Value> {
		.init { key, environment in
			let result = try? await self.load(key, environment)
			return result ?? value
		} save: { key, value, environment in
			try await self.save(key, value, environment)
		} remove: { key, environment in
			try await self.remove(key, environment)
		}
	}
	
	public func update(
		_ key: Key,
		environment: Environment,
		_ modify: @escaping (inout Value) -> Void
	) async throws -> Value {
		var value = try await self.load(key, environment)
		modify(&value)
		return try await self.save(key, value, environment)
	}
}

extension IndexedStore where Environment == Void {
	public func update(
		_ key: Key,
		_ modify: @escaping (inout Value) -> Void
	) async throws -> Value {
		var value = try await self.load(key, ())
		modify(&value)
		return try await self.save(key, value, ())
	}
}

extension IndexedStore {
	public func map<NewValue>(
		_ transformInput: @escaping (NewValue) -> Value,
		_ transformOutput: @escaping (Value) -> NewValue
	) -> IndexedStore<Environment, Key, NewValue> {
		.init { key, environment in
			let loaded = try await self.load(key, environment)
			return transformOutput(loaded)
		} save: { key, newValue, environment in
			let saved = try await self.save(key, transformInput(newValue), environment)
			return transformOutput(saved)
		} remove: { key, environment in
			try await self.remove(key, environment)
		}
	}
	
	public func map<NewValue>(
		_ conversion: Conversion<NewValue, Value>
	) -> IndexedStore<Environment, Key, NewValue> {
		self.map(conversion.to, conversion.from)
	}
}

extension IndexedStore {
	public func mapError<NewError: Error>(
		_ transformError: @escaping (Error) -> NewError
	) -> IndexedStore<Environment, Key, Value> {
		.init { key, environment in
			do {
				return try await self.load(key, environment)
			}
			catch let error {
				throw(transformError(error))
			}
		} save: { key, value, environment in
			do {
				return try await self.save(key, value, environment)
			}
			catch let error {
				throw transformError(error)
			}
		} remove: { key, environment in
			do {
				try await self.remove(key, environment)
			}
			catch let error{
				throw transformError(error)
			}
		}
	}
}

extension IndexedStore {
	public func load(
		_ key: Key,
		default value: Value,
		environment: Environment
	) async -> Value {
		(try? await self.load(key, environment)) ?? value
	}
}

extension IndexedStore where Environment == Void {
	public func load(
		_ key: Key,
		default value: Value
	) async -> Value {
		(try? await self.load(key, ())) ?? value
	}
}


public extension IndexedStore where Environment == Void {
	func cached(
		load: @escaping () async throws -> Value,
		key: Key
	) async throws -> Value {
		try await self.cached(
			load: load,
			key: key,
			environment: ()
		)
	}
}

public extension IndexedStore {
	func cached(
		load: @escaping (Environment) async throws -> Value,
		key: Key,
		environment: Environment
	) async throws -> Value {
		let value: Value
		
		do {
			value = try await self.load(key, environment)
		} catch {
			value = try await load(environment)
		}
		
		return try await self.save(key, value, environment)
	}
}
