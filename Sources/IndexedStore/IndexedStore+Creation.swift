import Foundation

import ValueStore

extension IndexedStore {
	public static func const(
		_ value: Value
	) -> Self {
		.init { _, _ in
			value
		} save: { _, _, _ in
			value
		} remove: { _, _ in
			()
		}
	}
	
	public static func error(
		_ error: Error
	) -> Self {
		.init { _, _ in
			throw(error)
		} save: { _, _, _ in
			throw(error)
		} remove: { _, _ in
			throw(error)
		}
	}
	
	public func replacing(
		_ oldStore: IndexedStore<Environment, Key, Value>
	) -> Self {
		.init { key, environment in
			do {
				let result = try await self.load(key, environment)
				try? await oldStore.remove(key, environment)
				return result
			}
			catch {
				return try await oldStore.move(key: key, to: self, environment: environment)
			}
		} save: { key, value, environment in
			try await self.save(key, value, environment)
		} remove: { key, environment in
			try await self.remove(key, environment)
			try? await oldStore.remove(key, environment)
		}
	}
}

extension Reference {
	public func indexedStore<Key: Hashable, StoreValue>() -> IndexedStore<Void, Key, StoreValue>
	where Value == Dictionary<Key, StoreValue> {
		.init { key in
			self.value = self.value ?? [:]
			guard let value = self.value?[key] else {
				throw ValueStoreError.noData
			}
			
			return value
		} save: { key, value in
			self.value = self.value ?? [:]
			guard var dic = self.value else {
				throw ValueStoreError.noData
			}
			dic[key] = value
			self.value = dic
			return value
		} remove: { key in
			self.value = self.value ?? [:]
			self.value?[key] = nil
		}
	}
}
