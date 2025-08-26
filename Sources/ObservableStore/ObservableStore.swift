import Foundation

import ValueStore

public struct ObservableStore<Environment, Value> {
	public var store: ValueStore<Environment, Value>
	public var updates: AsyncStream<Value>
	
	public init(
		store: ValueStore<Environment, Value>,
		updates: AsyncStream<Value>
	) {
		self.store = store
		self.updates = updates
	}
}
