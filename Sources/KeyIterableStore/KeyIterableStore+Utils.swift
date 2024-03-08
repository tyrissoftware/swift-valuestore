import Foundation

import ValueStore
import IndexedStore

extension KeyIterableStore {
	public func `default`(
		_ value: Value
	) -> KeyIterableStore<Environment, Key, Value> {
		.init(
			indexed: self.indexed.default(value),
			allKeys: self.allKeys
		)
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

extension KeyIterableStore where Environment == Void {
	public func update(
		_ key: Key,
		_ modify: @escaping (inout Value) -> Void
	) async throws -> Value {
		var value = try await self.load(key, ())
		modify(&value)
		return try await self.save(key, value, ())
	}
}

extension KeyIterableStore {
	public func map<NewValue>(
		_ transformInput: @escaping (NewValue) -> Value,
		_ transformOutput: @escaping (Value) -> NewValue
	) -> KeyIterableStore<Environment, Key, NewValue> {
		.init(
			indexed: self.indexed.map(transformInput, transformOutput),
			allKeys: self.allKeys
		)
	}
	
	public func map<NewValue>(
		_ conversion: Conversion<NewValue, Value>
	) -> KeyIterableStore<Environment, Key, NewValue> {
		self.map(conversion.to, conversion.from)
	}
}

extension KeyIterableStore {
	public func mapError<NewError: Error>(
		_ transformError: @escaping (Error) -> NewError
	) -> KeyIterableStore<Environment, Key, Value> {
		.init(
			indexed: self.indexed.mapError(transformError),
			allKeys: self.allKeys
		)
	}
}

extension KeyIterableStore {
	public func load(
		_ key: Key,
		default value: Value,
		environment: Environment
	) async -> Value {
		(try? await self.load(key, environment)) ?? value
	}
}

extension KeyIterableStore where Environment == Void {
	public func load(
		_ key: Key,
		default value: Value
	) async -> Value {
		(try? await self.load(key, ())) ?? value
	}
}


public extension KeyIterableStore where Environment == Void {
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

public extension KeyIterableStore {
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
