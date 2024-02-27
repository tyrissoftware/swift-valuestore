import Foundation

import ValueStore

extension IndexedStore {
	public func pullbackKey<NewKey>(
		_ f: @escaping (NewKey) -> Key
	) -> IndexedStore<Environment, NewKey, Value> {
		.init { newKey, environment in
			try await self.load(f(newKey), environment)
		} save: { newKey, value, environment in
			try await self.save(f(newKey), value, environment)
		} remove: { newKey, environment in
			try await self.remove(f(newKey), environment)
		}
	}
	
	public func valueStore(
		key: Key
	) -> ValueStore<Environment, Value> {
		.init { environment in
			try await self.load(key, environment)
		} save: { value, environment in
			try await self.save(key, value, environment)
		} remove: { environment in
			try await self.remove(key, environment)
		}
	}
}
