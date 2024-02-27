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
}

extension Reference {
	public func indexedStore<Key: Hashable, StoreValue>() -> IndexedStore<Void, Key, StoreValue>
	where Value == Dictionary<Key, StoreValue> {
		.init { key in
			guard let value = self.value?[key] else {
				throw ValueStoreError.noData
			}
			
			return value
		} save: { key, value in
			guard var dic = self.value else {
				throw ValueStoreError.noData
			}
			dic[key] = value
			self.value = dic
			return value
		} remove: { key in
			self.value?[key] = nil
		}
	}
}
