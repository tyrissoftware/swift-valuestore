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
}

extension Reference {
	public func keyIterableStore<Key: Hashable, StoreValue>() -> KeyIterableStore<Void, Key, StoreValue>
	where Value == Dictionary<Key, StoreValue> {
		.init(
			indexed: self.indexedStore()
		) {
			self.value = self.value ?? [:]
			return self.value?.keys.map { $0 } ?? []
		}
	}
}
