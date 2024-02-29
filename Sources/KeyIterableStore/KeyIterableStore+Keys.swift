import Foundation

import ValueStore

extension KeyIterableStore {
	public func transformKey<NewKey>(
		to: @escaping (NewKey) -> Key,
		from: @escaping (Key) -> NewKey
	) -> KeyIterableStore<Environment, NewKey, Value> {
		.init(
			indexed: self.indexed.pullbackKey(to),
			allKeys: {
				self.allKeys().map(from)
			}
		)
	}
	
	public func valueStore(
		key: Key
	) -> ValueStore<Environment, Value> {
		self.indexed.valueStore(key: key)
	}
}
