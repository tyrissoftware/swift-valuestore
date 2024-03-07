import Foundation

import ValueStore

extension KeyIterableStore {
	public static func const(
		_ value: Value
	) -> Self {
		.init(
			indexed: .const(value),
			allKeys: { [] }
		)
	}
	
	public static func error(
		_ error: Error
	) -> Self {
		.init(
			indexed: .error(error),
			allKeys: { [] }
		)
	}
	
	
	public func replacing(
		_ oldStore: KeyIterableStore<Environment, Key, Value>
	) -> Self {
		.init(
			indexed: self.indexed.replacing(oldStore.indexed),
			allKeys: self.allKeys
		)
	}
}

extension Reference {
	public func keyIterableStore<Key: Hashable & Comparable, StoreValue>() -> KeyIterableStore<Void, Key, StoreValue>
	where Value == Dictionary<Key, StoreValue> {
		.init(
			indexed: self.indexedStore()
		) {
			self.value = self.value ?? [:]
			return self.value?.keys.map { $0 }.sorted(by: { $0 < $1 }) ?? []
		}
	}
}
